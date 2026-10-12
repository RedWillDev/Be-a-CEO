local Players = game:GetService("Players")
local Studio = game:GetService("RunService"):IsStudio()
local TweenService = game:GetService("TweenService")
local L = {}
function L.Start(sessions, W, E, P, send, valid, otherCarry)
 local self = {Parcels = {}, Carries = {}}
 local function root(player)
  local c = player.Character local h = c and c:FindFirstChildOfClass("Humanoid")
  local r = c and c:FindFirstChild("HumanoidRootPart")
  if not h or h.Health <= 0 or h.SeatPart then return nil end
  return r, h
 end
 local function reset(player)
  local carry = self.Carries[player]
  if carry then
   if carry.PickupTween then carry.PickupTween:Cancel() carry.PickupTween = nil end
   if carry.Grip then carry.Grip:Destroy() carry.Grip = nil end
   if carry.Owner and carry.Model.Parent then carry.Model.PrimaryPart.Anchored = true end
   if carry.Character then
    carry.Character:SetAttribute("CarryingTourist", nil)
    carry.Character:SetAttribute("CarryingParcel", nil)
   end
  end
  local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = 16 end
  self.Carries[player] = nil
 end
 function self:Busy(player) return self.Carries[player] ~= nil end
 function self:Drop(player)
  local carry = self.Carries[player]
  if not carry then return end
  reset(player)
  if carry.Owner then
   carry.Carrier = nil
   if carry.Model.Parent then carry.Model:PivotTo(carry.Home) carry.Prompt.Enabled = true end
  elseif carry.Model.Parent then
   carry.Model:SetAttribute("Carried", false)
   if carry.Prompt then carry.Prompt.Enabled = true end
   W.TouristWalk(carry.Model)
  end
 end
 function self:Remove(player)
  self:Drop(player)
  local parcel = self.Parcels[player]
  if parcel then
   if parcel.Carrier then self:Drop(parcel.Carrier) end
   parcel.Model:Destroy() self.Parcels[player] = nil
  end
 end
 function self:Receive(owner, recipient)
  local a, b = sessions[owner], sessions[recipient]
  if not a or not b or not valid(owner) or not valid(recipient) then return false end
  local parcel = a.Data.Parcel
  if not parcel or b.Data.Product ~= parcel.Product or b.Data.Stock + parcel.Units > 50 then return false end
  -- Cross-profile transfers are experimental and deliberately unavailable on live servers.
  if owner ~= recipient and (not Studio or not a.Data.Rivalry or not b.Data.Rivalry or a.Data.Level < 2 or b.Data.Level < 2) then return false end
  local d = b.Data
  d.Quality = (d.Stock * d.Quality + parcel.Units * parcel.Quality) / (d.Stock + parcel.Units)
  d.Stock += parcel.Units a.Data.Parcel = nil
  if owner ~= recipient then
   a.Data.Cash += math.floor((parcel.Paid or 0) * 0.5)
   send(owner, "Colis dérobé : assurance de 50 % du prix d'achat remboursée. Mode expérimental Studio.")
  end
  local visual = self.Parcels[owner]
  if visual then
   if visual.Carrier then reset(visual.Carrier) end
   visual.Model:Destroy() self.Parcels[owner] = nil
  end
  send(recipient, "Colis rangé : +" .. parcel.Units .. " produits en stock !")
  return true
 end
 function self:Spawn(owner, s)
  local m = Instance.new("Model") m.Name, m.Parent = "DeliveryParcel", W.City
  local cf = W.Plots[s.Plot].CF * CFrame.new(9, 1.15, -19)
  local part = W.Part(m, "Box", Vector3.new(2.4, 1.8, 1.8), cf, Color3.fromRGB(181, 132, 81))
  part.CanCollide, part.CanTouch, part.Massless = false, false, true m.PrimaryPart = part
  local prompt = Instance.new("ProximityPrompt")
  prompt.ActionText, prompt.ObjectText = "Porter", "Colis de " .. owner.DisplayName
  prompt.HoldDuration, prompt.MaxActivationDistance, prompt.RequiresLineOfSight, prompt.Parent = 0.6, 9, false, part
  local entry = {Owner = owner, Model = m, Prompt = prompt, Home = cf, Created = os.clock()}
  self.Parcels[owner] = entry
  prompt.Triggered:Connect(function(player)
   local r, h = root(player)
   if not r or not valid(player) or not valid(owner) or self:Busy(player) or otherCarry(player) or entry.Carrier or not s.Data.Parcel then return end
   if (r.Position - part.Position).Magnitude > 11 then return end
   local d = sessions[player].Data
   if player ~= owner then
    if not Studio or not d.Rivalry or not s.Data.Rivalry or d.Level < 2 or s.Data.Level < 2 or os.clock() - entry.Created < 20 then send(player, "Colis protégé. Vol : test Studio, entreprises volontaires niveau 2+, après 20 s.") return end
   end
   if d.Product ~= s.Data.Parcel.Product then send(player, "Ce colis ne correspond pas au produit de ta boutique.") return end
   entry.Carrier = player entry.LastPosition = r.Position self.Carries[player] = entry prompt.Enabled = false h.WalkSpeed = 11
   entry.Character = player.Character
   player.Character:SetAttribute("CarryingParcel", true)
   -- Attach to the character assembly: no server-position updates during walking.
   -- Tween the grip in character space for the pickup, then keep a fixed hold.
   local grip = Instance.new("Motor6D")
   grip.Name, grip.Part0, grip.Part1 = "ParcelGrip", r, part
   grip.C0 = r.CFrame:ToObjectSpace(part.CFrame)
   part.Anchored = false
   grip.Parent = r entry.Grip = grip
   local scale = math.clamp((h.HipHeight + r.Size.Y / 2) / 3, 0.8, 1.25)
   if h.RigType == Enum.HumanoidRigType.R6 then scale = 1 end
   entry.PickupTween = TweenService:Create(grip, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C0 = CFrame.new(0, -0.15 * scale, -1.7 * scale)})
   entry.PickupTween:Play()
   send(player, "Porte le colis jusqu'au comptoir de ta boutique. Pas de voiture ni téléportation.")
  end)
 end
 function self:AddTourist(model)
  local prompt = Instance.new("ProximityPrompt")
  prompt.ActionText, prompt.ObjectText, prompt.HoldDuration = "Accompagner", "Vacancier • vente x2", 0.5
  prompt.MaxActivationDistance, prompt.RequiresLineOfSight, prompt.Parent = 9, false, model.PrimaryPart
  prompt.Triggered:Connect(function(player)
   local r, h = root(player)
   if not r or not model.Parent or not prompt.Enabled or not valid(player) or self:Busy(player) or otherCarry(player) then return end
   if (r.Position - model.PrimaryPart.Position).Magnitude > 11 or sessions[player].Data.Stock < 1 then return end
   prompt.Enabled = false model.Parent = W.City
   -- Reparenting protects carried tourists from event cleanup; retain a bounded lifetime.
   if not model:GetAttribute("CarryExpiryScheduled") then
    model:SetAttribute("CarryExpiryScheduled", true)
    game:GetService("Debris"):AddItem(model, 240)
   end
   model:SetAttribute("Carried", true)
   player.Character:SetAttribute("CarryingTourist", true)
   self.Carries[player] = {Model = model, Tourist = true, Prompt = prompt, Character = player.Character, Started = os.clock(), LastPosition = r.Position}
   h.WalkSpeed = 11 send(player, "Ramène le vacancier à ton comptoir pour une vente x2 !")
  end)
 end
 function self:Tick()
  for owner, s in pairs(sessions) do
   if valid(owner) and s.Data.Parcel then
    if not self.Parcels[owner] then self:Spawn(owner, s) end
    local entry = self.Parcels[owner]
    local rank = s.Data.Staff and s.Data.Staff.Receiver or 0
    if rank > 0 and not entry.Carrier and os.clock() - entry.Created >= 16 - rank * 4 then self:Receive(owner, owner) end
   end
  end
  for player, carry in pairs(self.Carries) do
   local r = root(player) local s = sessions[player]
   if not r or not valid(player) or not carry.Model.Parent or (carry.Owner and not valid(carry.Owner)) or (carry.Started and os.clock() - carry.Started > 90) or (r and carry.LastPosition and (r.Position - carry.LastPosition).Magnitude > 40) then self:Drop(player)
   else
    carry.LastPosition = r.Position
    local counter = W.Plots[s.Plot].CF * CFrame.new(0, 2, 0)
    if (r.Position - counter.Position).Magnitude < 9 then
     if carry.Owner then self:Receive(carry.Owner, player)
     else
      if W.CheckIn and W.CheckIn(player, carry.Model, 2, "Touriste") then
       reset(player) send(player, "Vacancier accueilli : encaisse-le au comptoir.")
      end
     end
    end
   end
  end
 end
 -- Smooth passenger following is visual only; all delivery checks stay in Tick.
 game:GetService("RunService").Heartbeat:Connect(function()
  for player, carry in pairs(self.Carries) do
   if carry.Tourist and carry.Model.Parent then
    local r = root(player)
    if r then carry.Model:PivotTo(r.CFrame * CFrame.new(0, 0.4, -1.7) * CFrame.Angles(0, math.pi / 2, 0)) end
   end
  end
 end)
 return self
end
return L
