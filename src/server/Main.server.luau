local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local DataStoreService = game:GetService("DataStoreService")
local shared = game.ReplicatedStorage.BeACEO
local C = require(shared.Config)
local E = require(script.Parent.Economy)
local W = require(script.Parent.World)
local remote = Instance.new("RemoteEvent") remote.Name = "Command" remote.Parent = shared
local stateRemote = Instance.new("RemoteEvent") stateRemote.Name = "State" stateRemote.Parent = shared
local sessions, cars = {}, {}
local studio = RunService:IsStudio()
local store = not studio and DataStoreService:GetDataStore("BeACEO_Profiles_v1") or nil
local lockId = game.JobId .. ":" .. game:GetService("HttpService"):GenerateGUID(false)
local trend, nextTrend, vip, carrier = 1, os.clock() + 90, nil, nil
W.Build()
local function send(player, message)
 local s = sessions[player]
 if not s then return end
 stateRemote:FireClient(player, {Data = s.Data, Plot = s.Plot, Trend = trend, TrendSeconds = math.max(0, math.ceil(nextTrend - os.clock())), Message = message, Saving = s.Status, Carrying = carrier == player})
end
local function save(player, release)
 local s = sessions[player]
 if not s or not store then return true end
 while s.Saving do task.wait(0.1) end
 s.Saving = true
 local snapshot = game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):JSONEncode(s.Data))
 local success = false
 for attempt = 1, 3 do
  local ok, result = pcall(function()
   return store:UpdateAsync("Player_" .. player.UserId, function(old)
    if old and old.Lock and old.Lock.Id ~= lockId then return nil end
    return {Data = snapshot, Version = 1, Lock = not release and {Id = lockId, Time = os.time()} or nil}
   end)
  end)
  if ok and result then success = true break end
  task.wait(attempt)
 end
 s.Saving = false s.Status = success and "Sauvegarde active" or "Échec sauvegarde • nouvelle tentative"
 if success then s.LastSaved = os.time() end
 return success
end
local function arrive(player, character)
 local s = sessions[player]
 local root = character:WaitForChild("HumanoidRootPart", 10)
 if s and root and character.Parent then character:PivotTo(W.Plots[s.Plot].CF * CFrame.new(0, 4, -21)) W.ApplyPersonal(player, s.Data) end
end
local function join(player)
 local taken = {} for _, s in pairs(sessions) do taken[s.Plot] = true end
 local index for i = 1, 8 do if not taken[i] then index = i break end end
 if not index then player:Kick("Les 8 entreprises sont occupées. Rejoins un autre serveur.") return end
 local s = {Plot = index, Data = E.New(), Status = studio and "Test Studio • progression temporaire" or "Chargement…", LastAction = 0, LastSaved = os.time(), Ready = false}
 sessions[player] = s
 if store then
  local ok, profile = pcall(function()
   return store:UpdateAsync("Player_" .. player.UserId, function(old)
    if old and old.Lock and old.Lock.Id ~= lockId and os.time() - old.Lock.Time < 180 then return nil end
    local result = old or {Data = E.New(), Version = 1}
    result.Lock = {Id = lockId, Time = os.time()}
    return result
   end)
  end)
  if not ok or not profile then sessions[player] = nil player:Kick("Profil indisponible ou déjà ouvert. Réessaie dans quelques instants ; aucune donnée remplacée.") return end
  for key, value in pairs(profile.Data) do s.Data[key] = value end
  s.Status = "Sauvegarde active"
 end
 if player.Parent ~= Players then save(player, true) sessions[player] = nil return end
 s.Ready = true
 W.UpdatePlot(index, player, s.Data)
 player.CharacterAdded:Connect(function(char) arrive(player, char) end)
 if player.Character then task.spawn(arrive, player, player.Character) end
 local stats = Instance.new("Folder") stats.Name = "leaderstats" stats.Parent = player
 local sales = Instance.new("IntValue") sales.Name = "Ventes" sales.Parent = stats
 local level = Instance.new("IntValue") level.Name = "Entreprise" level.Parent = stats
 send(player, "Bienvenue ! Choisis un produit puis commande ton premier lot sur MarketBridge.")
end
local function dropVIP()
 if carrier and carrier.Character then local h = carrier.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = 16 end end
 carrier = nil
 if vip then vip:Destroy() vip = nil end
end
Players.PlayerRemoving:Connect(function(player)
 local s = sessions[player]
 if not s then return end
 if carrier == player then dropVIP() end
 if cars[player] then cars[player].Model:Destroy() cars[player] = nil end
 if s.Ready then save(player, true) end
 sessions[player] = nil W.UpdatePlot(s.Plot, nil, nil)
end)
W.OnTerminal = function(player, index)
 local s = sessions[player]
 if not s or not s.Ready then return end
 send(player, s.Plot == index and "OPEN_MARKET" or "Cette entreprise appartient à un autre joueur.")
end
remote.OnServerEvent:Connect(function(player, action, value)
 local s = sessions[player]
 if not s or not s.Ready or type(action) ~= "string" then return end
 if os.clock() - s.LastAction < 0.15 then return end
 s.LastAction = os.clock()
 if action == "Ready" then send(player) return end
 if not studio and os.time() - s.LastSaved > 110 then send(player, "Sauvegarde en retard : achats suspendus pour protéger ta progression.") return end
 if value ~= nil and type(value) ~= "number" and type(value) ~= "string" then return end
 if type(value) == "number" and (value ~= value or value % 1 ~= 0 or math.abs(value) > 10) then return end
 if action == "Home" then
  if player.Character then local hum = player.Character:FindFirstChildOfClass("Humanoid") if hum and hum.SeatPart then send(player, "Descends du véhicule avant de rentrer.") return end arrive(player, player.Character) end
  return
 end
 if action == "Drop" then if carrier == player then dropVIP() end return end
 if action == "Vehicle" and cars[player] and cars[player].Seat.Occupant then send(player, "Descends du véhicule avant de le remplacer.") return end
 local ok, message = E.Action(s.Data, action, value, os.clock())
 if ok then
  if action == "Upgrade" or action == "Color" or action == "Luxury" or action == "Product" then W.UpdatePlot(s.Plot, player, s.Data) end
  if action == "Luxury" then W.ApplyPersonal(player, s.Data) end
  if action == "Vehicle" then
   if cars[player] then cars[player].Model:Destroy() end
   cars[player] = W.Car(s.Plot, value, player)
  end
 end
 send(player, message)
end)
local function customer(s, amount, disputed)
 local cf = W.Plots[s.Plot].CF
 local npc = W.Person(W.City, "Client", cf * CFrame.new(0, 0, -23), disputed and C.Palette[2] or C.Palette[3])
 local value = Instance.new("CFrameValue") value.Value = npc:GetPivot()
 local connection = value.Changed:Connect(function(cframe) if npc.Parent then npc:PivotTo(cframe) end end)
 local tween = TweenService:Create(value, TweenInfo.new(2), {Value = value.Value * CFrame.new(0, 0, 12)}) tween:Play()
 local label = Instance.new("BillboardGui") label.Size, label.StudsOffset, label.AlwaysOnTop = UDim2.fromOffset(180, 38), Vector3.new(0, 4, 0), true label.Parent = npc.PrimaryPart
 local text = Instance.new("TextLabel") text.Size, text.BackgroundTransparency, text.Text = UDim2.fromScale(1, 1), 1, "+" .. amount .. " $ • " .. (disputed and "Tendance !" or "Merci !") text.TextColor3, text.TextSize, text.Font, text.Parent = C.Palette[1], 17, Enum.Font.GothamBold, label
 task.delay(4, function() connection:Disconnect() value:Destroy() npc:Destroy() end)
end
local seconds = 0
task.spawn(function()
 while true do
  task.wait(1) seconds += 1
  if os.clock() >= nextTrend then trend = trend % #C.Products + 1 nextTrend = os.clock() + 90 end
  if not vip and seconds % 25 == 0 then
   vip = W.Person(W.City, "ClientVIP", CFrame.new(0, 21, -125), Color3.fromRGB(239, 195, 83))
   local prompt = Instance.new("ProximityPrompt") prompt.ActionText, prompt.ObjectText, prompt.HoldDuration = "Accompagner", "Client VIP • vente x3", 0.5 prompt.MaxActivationDistance, prompt.RequiresLineOfSight, prompt.Parent = 10, false, vip.PrimaryPart
   prompt.Triggered:Connect(function(player)
    local s = sessions[player] local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not vip or carrier or not s or not s.Ready or not root or (root.Position - vip.PrimaryPart.Position).Magnitude > 12 then return end
    if s.Data.Stock < 1 then send(player, "Il te faut du stock pour accueillir ce client.") return end
    carrier = player prompt.Enabled = false
    player.Character.Humanoid.WalkSpeed = 11
    send(player, "Ramène le VIP à ton comptoir : une vente à triple prix !")
   end)
  end
  if carrier then
   local root = carrier.Character and carrier.Character:FindFirstChild("HumanoidRootPart")
   local hum = carrier.Character and carrier.Character:FindFirstChildOfClass("Humanoid")
   local s = sessions[carrier]
   if not root or not hum or hum.Health <= 0 or hum.SeatPart or not s then dropVIP()
   else
    vip:PivotTo(root.CFrame * CFrame.new(0, 3, 1))
    if (root.Position - W.Plots[s.Plot].CF.Position).Magnitude < 16 then
     local amount = E.Sale(s.Data, 3) local player = carrier dropVIP()
     send(player, amount > 0 and ("VIP livré : +" .. amount .. " $ !") or "Plus de stock : le client repart.")
    end
   end
  end
  for player, s in pairs(sessions) do
   if not s.Ready then continue end
   local d = s.Data
   if d.Order then
    d.Order.Remaining -= 1
    if d.Order.Remaining <= 0 then d.Quality = (d.Stock * d.Quality + 10 * d.Order.Quality) / (d.Stock + 10) d.Stock += 10 d.Order = nil send(player, "Livraison reçue : 10 produits prêts à vendre !") end
   end
   local interval = d.PriceMode == 3 and 7 or d.PriceMode == 1 and 3 or 5
   if seconds % interval == 0 and d.Stock > 0 then local amount = E.Sale(d) customer(s, amount, false) end
   if player:FindFirstChild("leaderstats") then player.leaderstats.Ventes.Value = d.Sales player.leaderstats.Entreprise.Value = d.Level end
   send(player)
  end
  -- One contested customer per server cycle, scored by product, quality and price.
  if seconds % 9 == 0 then
   local winner, score
   for player, s in pairs(sessions) do
    if s.Ready and s.Data.Stock > 0 then
     local candidate = math.random() * 2 + s.Data.Quality + (s.Data.Product == trend and 2 or 0) - s.Data.PriceMode * 0.35
     if not score or candidate > score then winner, score = player, candidate end
    end
   end
   if winner then local s = sessions[winner] local amount = E.Sale(s.Data, 1.25) customer(s, amount, true) send(winner) end
  end
  if seconds % 45 == 0 then for player, s in pairs(sessions) do if s.Ready then task.spawn(save, player, false) end end end
 end
end)
RunService.Heartbeat:Connect(function(dt)
 for player, car in pairs(cars) do
  local occupant = car.Seat.Occupant
  if occupant and Players:GetPlayerFromCharacter(occupant.Parent) ~= player then occupant.Sit = false continue end
  local throttle = occupant and car.Seat.ThrottleFloat or 0
  car.Speed += (throttle * C.Vehicles[car.Tier].Speed - car.Speed) * math.min(dt * 3, 1)
  if math.abs(car.Speed) > 0.1 then
   local cf = car.Model:GetPivot()
   local steer = occupant and car.Seat.SteerFloat or 0
   local nextCF = cf * CFrame.Angles(0, -steer * dt * 1.6 * math.sign(car.Speed), 0) * CFrame.new(0, 0, -car.Speed * math.min(dt, 0.1))
   local params = RaycastParams.new() params.FilterType = Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances = {car.Model, player.Character} params.RespectCanCollide = true
   local delta = nextCF.Position - cf.Position
   local hit = delta.Magnitude > 0.001 and workspace:Blockcast(cf, Vector3.new(6.5, 1.5, 11 + car.Tier * 0.4), delta, params)
   if not hit and math.abs(nextCF.X) < 180 and math.abs(nextCF.Z) < 140 then car.Model:PivotTo(nextCF) else car.Speed = 0 end
  end
 end
end)
Players.PlayerAdded:Connect(join)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(join, player) end
game:BindToClose(function()
 local remaining = 0
 for player, s in pairs(sessions) do if s.Ready then remaining += 1 task.spawn(function() save(player, true) remaining -= 1 end) end end
 local deadline = os.clock() + 25 while remaining > 0 and os.clock() < deadline do task.wait(0.1) end
end)
print("[Be-a-CEO] Gameplay ready: 8 plots, MarketBridge, economy, personal purchases, vehicles and VIP.")
