local Players = game:GetService("Players")
local Studio = game:GetService("RunService"):IsStudio()
local Carry = require(script.Parent.Carry)
local EventInfo = require(game.ReplicatedStorage.BeACEO.EventInfo)
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
  if carry and carry.Handle then carry.Handle:Detach() carry.Handle = nil end
  self.Carries[player] = nil
 end
 function self:Busy(player) return self.Carries[player] ~= nil end
 function self:CancelReceiver(entry)
  local job = entry.ReceiverJob
  if not job then return end
  entry.ReceiverJob = nil
  if job.Handle then job.Handle:Detach() end
  if job.Employee.Parent then W.StopRoute(job.Employee) job.Employee:SetAttribute("ReceiverStatus", "Disponible") end
  if entry.Model.Parent and not entry.Carrier then entry.Model:PivotTo(entry.Home) entry.Prompt.Enabled = true end
  entry.RetryAt = os.clock() + 3
 end
 function self:DispatchReceiver(owner, s, entry, rank)
  local plot = W.Plots[s.Plot]
  local employee = plot.Model and plot.Model:FindFirstChild("Receiver")
  if not employee or not employee.PrimaryPart or employee.Humanoid.Health <= 0 then return end
  local job = {Employee = employee, Phase = "Approach", Started = os.clock()}
  entry.ReceiverJob = job
  local cf, speed = plot.CF, 6 + rank * 2
  local function current()
   return entry.ReceiverJob == job and self.Parcels[owner] == entry and valid(owner) and s.Data.Parcel and not entry.Carrier and employee.Parent and employee.Humanoid.Health > 0 and entry.Model.Parent
  end
  employee:SetAttribute("ReceiverStatus", "Va chercher le colis")
  W.Route(employee, {(cf * CFrame.new(13, 3.5, -15)).Position, (cf * CFrame.new(9, 3.5, -19)).Position}, function(reached)
   if entry.ReceiverJob ~= job then return end
   if not reached or not current() or (employee.PrimaryPart.Position - entry.Model.PrimaryPart.Position).Magnitude > 6 then self:CancelReceiver(entry) return end
   -- Claim atomically before attaching: a player can win the pickup until this point.
   entry.Prompt.Enabled = false job.Phase = "Return"
   job.Handle = Carry.new(employee, entry.Model, "Parcel"):Attach()
   employee:SetAttribute("ReceiverStatus", "Ramène le colis")
   W.Route(employee, {(cf * CFrame.new(13, 3.5, -15)).Position, (cf * CFrame.new(13, 3.5, -7)).Position}, function(returned)
    if entry.ReceiverJob ~= job then return end
    local destination = (cf * CFrame.new(13, 3.5, -7)).Position
    if not returned or not current() or (employee.PrimaryPart.Position - destination).Magnitude > 3 then self:CancelReceiver(entry) return end
    job.Handle:Detach() job.Handle = nil
    entry.ReceiverJob = nil employee:SetAttribute("ReceiverStatus", "Disponible")
    if not self:Receive(owner, owner) then
     entry.Model:PivotTo(entry.Home) entry.Prompt.Enabled = true entry.RetryAt = os.clock() + 3
    end
   end, speed)
  end, speed)
 end
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
   self:CancelReceiver(parcel)
   if parcel.Carrier then self:Drop(parcel.Carrier) end
   parcel.Model:Destroy() self.Parcels[player] = nil
  end
 end
 function self:Receive(owner, recipient)
  local a, b = sessions[owner], sessions[recipient]
  if not a or not b or not valid(owner) or not valid(recipient) then return false end
  local parcel = a.Data.Parcel
  if not parcel or b.Data.Product ~= parcel.Product or b.Data.Stock + parcel.Units > E.Capacity(b.Data) then return false end
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
   self:CancelReceiver(visual)
   if visual.Carrier then reset(visual.Carrier) end
   visual.Model:Destroy() self.Parcels[owner] = nil
  end
  send(recipient, "Colis rangé : +" .. parcel.Units .. " produits en stock !")
  return true
 end
 function self:Spawn(owner, s)
  local m = Instance.new("Model") m.Name, m.Parent = "DeliveryParcel", W.City
  m:SetAttribute("OwnerId", owner.UserId)
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
   if entry.ReceiverJob and entry.ReceiverJob.Phase == "Return" then return end
   self:CancelReceiver(entry)
   entry.Handle = Carry.new(player.Character, m, "Parcel"):Attach()
   entry.Carrier = player entry.LastPosition = r.Position self.Carries[player] = entry prompt.Enabled = false
   send(player, "Entre dans ta boutique avec le colis : il sera immédiatement rangé en stock.")
  end)
 end
 function self:AddTourist(model)
  local prompt = Instance.new("ProximityPrompt")
  prompt.Name = "CarryTourist"
  prompt.ActionText, prompt.ObjectText, prompt.HoldDuration = "Porter", "Vacancier • vente x2", 0
  prompt.MaxActivationDistance, prompt.RequiresLineOfSight, prompt.Parent = 9, false, model.PrimaryPart
  prompt.Triggered:Connect(function(player)
   local r, h = root(player)
   if not model.Parent or not model.PrimaryPart or not prompt.Enabled or model:GetAttribute("Carried") or model:GetAttribute("Shopping") then return end
   if not valid(player) then send(player, "Portage indisponible pendant le chargement ou la pause de sauvegarde.") return end
   if not r then send(player, "Descends du véhicule pour porter un vacancier.") return end
   if self:Busy(player) or otherCarry(player) then send(player, "Dépose d'abord ce que tu portes avec le bouton DÉPOSER.") return end
   if (r.Position - model.PrimaryPart.Position).Magnitude > 11 then send(player, "Rapproche-toi du vacancier pour le porter.") return end
   prompt.Enabled = false
   W.StopRoute(model)
   local handle
   local ok, failure = pcall(function()
    handle = Carry.new(player.Character, model, "Tourist")
    handle:Attach()
   end)
   if not ok then
    if handle then handle:Detach() end
    if model.Parent then prompt.Enabled = true W.TouristWalk(model) end
    warn("[Tourist carry] " .. tostring(failure))
    send(player, "Impossible de prendre ce vacancier pour le moment. Réessaie.")
    return
   end
   model.Parent = W.City
   -- Reparenting protects carried tourists from event cleanup; retain a bounded lifetime.
   if not model:GetAttribute("CarryExpiryScheduled") then
    model:SetAttribute("CarryExpiryScheduled", true)
    game:GetService("Debris"):AddItem(model, 240)
   end
   self.Carries[player] = {Handle = handle, Model = model, Tourist = true, Prompt = prompt, Character = player.Character, Started = os.clock(), LastPosition = r.Position}
   send(player, sessions[player].Data.Stock > 0 and "Ramène le vacancier à ton comptoir pour une vente x2 !" or "Vacancier porté ! Prévois du stock pour pouvoir l'accueillir et l'encaisser.")
  end)
 end
 function self:Tick()
  for owner, s in pairs(sessions) do
   if valid(owner) and s.Data.Parcel then
    if not self.Parcels[owner] then self:Spawn(owner, s) end
    local entry = self.Parcels[owner]
    local rank = s.Data.Staff and s.Data.Staff.Receiver or 0
    if rank > 0 and not entry.Carrier and not entry.ReceiverJob and os.clock() >= (entry.RetryAt or 0) and os.clock() - entry.Created >= 4 - rank then
     self:DispatchReceiver(owner, s, entry, rank)
    end
   end
  end
 end
 function self:UpdateCarries()
  for owner, entry in pairs(self.Parcels) do
   local job = entry.ReceiverJob
   if job and (not valid(owner) or not job.Employee.Parent or job.Employee.Humanoid.Health <= 0 or not entry.Model.Parent or os.clock() - job.Started > 45) then self:CancelReceiver(entry) end
  end
  for player, carry in pairs(self.Carries) do
   local r = root(player) local s = sessions[player]
   if not r or not valid(player) or not carry.Model.Parent or (carry.Handle and not carry.Handle.Attached) or (carry.Owner and not valid(carry.Owner)) or (carry.Started and os.clock() - carry.Started > 90) or (r and carry.LastPosition and (r.Position - carry.LastPosition).Magnitude > 40) then self:Drop(player)
   else
    carry.LastPosition = r.Position
    local counter = W.Plots[s.Plot].CF * CFrame.new(0, 2, 0)
    local inside = W.Plots[s.Plot].CF:PointToObjectSpace(r.Position)
    local inShop = math.abs(inside.X) < 17 and inside.Z > -12 and inside.Z < 15 and inside.Y > 0 and inside.Y < 8
    if (carry.Owner and inShop) or (not carry.Owner and (r.Position - counter.Position).Magnitude < 9) then
     if carry.Owner then self:Receive(carry.Owner, player)
     else
      if W.CheckIn and W.CheckIn(player, carry.Model, EventInfo.TouristBonus, "Touriste") then
       reset(player) send(player, "Vacancier accueilli : encaisse-le au comptoir.")
      end
     end
    end
   end
  end
 end
 -- Check delivery every physics frame, independently of the one-second economy tick.
 game:GetService("RunService").Heartbeat:Connect(function()
  self:UpdateCarries()
 end)
 return self
end
return L
