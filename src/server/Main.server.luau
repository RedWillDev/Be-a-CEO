local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local shared = game.ReplicatedStorage.BeACEO
local C = require(shared.Config)
local E = require(script.Parent.Economy)
local P = require(script.Parent.Progression)
local Staff = require(script.Parent.Staff)
local Logistics = require(script.Parent.Logistics)
local Carry = require(script.Parent.Carry)
local Customers = require(script.Parent.Customers)
local W = require(script.Parent.World)
local remote = Instance.new("RemoteEvent") remote.Name = "Command" remote.Parent = shared
local stateRemote = Instance.new("RemoteEvent") stateRemote.Name = "State" stateRemote.Parent = shared
local sessions, cars = {}, {}
local studio = RunService:IsStudio()
local store = not studio and DataStoreService:GetDataStore("BeACEO_Profiles_v1") or nil
local lockId = game.JobId .. ":" .. game:GetService("HttpService"):GenerateGUID(false)
local trend, nextTrend, vip, carrier = 1, os.clock() + 90, nil, nil
local cityEvent = {Kind = "Préparation", Product = 1, Ends = os.time() + 60, Units = 0, Target = 30}
local eventNumber = 0
local logistics
local customers
W.Build()
W.CityEvent(cityEvent)
local function send(player, message)
 local s = sessions[player]
 if not s then return end
 if s.Ready then W.UpdateStock(s.Plot, s.Data) end
 local board, total = {}, 0
 for participant, session in pairs(sessions) do
  if session.Ready then
   local wins = session.SessionDisputed or 0 total += wins
   table.insert(board, {Name = participant.DisplayName, Wins = wins, Level = session.Data.Level})
  end
 end
 table.sort(board, function(a, b) if a.Wins == b.Wins then return a.Name < b.Name end return a.Wins > b.Wins end)
 stateRemote:FireClient(player, {Data = s.Data, StaffRoles = Staff.Roles, Waiting = s.Waiting ~= nil, QueueCount = #(s.Customers or {}), Board = board, MarketShare = total > 0 and math.floor((s.SessionDisputed or 0) / total * 100) or 0, Progression = P.View(s.Data, os.time()), Event = cityEvent, Plot = s.Plot, Trend = trend, TrendSeconds = math.max(0, math.ceil(nextTrend - os.clock())), Message = message, Saving = s.Status, Carrying = carrier == player or (logistics and logistics:Busy(player))})
end
local function valid(player)
 local s = sessions[player]
 return s and s.Ready and not s.Closing and (studio or os.time() - s.LastSaved <= 110)
end
customers = Customers.new(W, valid, send)
logistics = Logistics.Start(sessions, W, E, P, send, valid, function(player) return carrier == player end)
W.OnTourist = function(model) logistics:AddTourist(model) end
local function save(player, release)
 local s = sessions[player]
 if not s or not store then return true end
 if release then s.Closing = true end
 while s.Saving do task.wait(0.1) end
 if s.Released or (s.Closing and not release) then return true end
 s.Saving = true
 local snapshot = game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):JSONEncode(s.Data))
 snapshot.LastSeen = os.time()
 local success = false
 for attempt = 1, 3 do
  local ok, result = pcall(function()
   return store:UpdateAsync("Player_" .. player.UserId, function(old)
    if not old or not old.Lock or old.Lock.Id ~= lockId then return nil end
    return {Data = snapshot, Version = 1, Lock = not release and {Id = lockId, Time = os.time()} or nil}
   end)
  end)
  if ok and result then success = true break end
  task.wait(attempt)
 end
 s.Saving = false s.Status = success and "Sauvegarde active" or "Échec sauvegarde • nouvelle tentative"
 if success then s.LastSaved = os.time() end
 if success and release then s.Released = true end
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
 local offlineEarned = 0
 if store then
  local ok, profile = pcall(function()
   return store:UpdateAsync("Player_" .. player.UserId, function(old)
    if old and old.Lock and old.Lock.Id ~= lockId and os.time() - old.Lock.Time < 180 then return nil end
    local result = old or {Data = E.New(), Version = 1}
    offlineEarned = P.Offline(result.Data, os.time(), E.Sale)
    result.Lock = {Id = lockId, Time = os.time()}
    return result
   end)
  end)
  if not ok or not profile then sessions[player] = nil player:Kick("Profil indisponible ou déjà ouvert. Réessaie dans quelques instants ; aucune donnée remplacée.") return end
  for key, value in pairs(profile.Data) do s.Data[key] = value end
  s.Status = "Sauvegarde active"
 end
 if player.Parent ~= Players then save(player, true) sessions[player] = nil return end
 P.Init(s.Data, os.time())
 Staff.Init(s.Data)
 s.Ready = true
 W.UpdatePlot(index, player, s.Data)
 player.CharacterAdded:Connect(function(char) arrive(player, char) end)
 if player.Character then task.spawn(arrive, player, player.Character) end
 local stats = Instance.new("Folder") stats.Name = "leaderstats" stats.Parent = player
 local sales = Instance.new("IntValue") sales.Name = "Ventes" sales.Parent = stats
 local level = Instance.new("IntValue") level.Name = "Entreprise" level.Parent = stats
 send(player, offlineEarned > 0 and ("Bon retour ! Ventes hors ligne : +" .. offlineEarned .. " $ (stock existant, moitié du prix, 4 h maximum).") or "Bienvenue ! Choisis un produit puis commande ton premier lot sur MarketBridge.")
end
local function dropVIP()
 if vip then Carry.Release(vip) end
 if carrier and carrier.Character then local h = carrier.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = 16 end end
 carrier = nil
 if vip then vip:Destroy() vip = nil end
end
Players.PlayerRemoving:Connect(function(player)
 local s = sessions[player]
 if not s then return end
 if carrier == player then dropVIP() end
 logistics:Remove(player)
 if s.Delivery and s.Delivery.Model then s.Delivery.Model:Destroy() end
 customers:Clear(s)
 if cars[player] then cars[player].Model:Destroy() cars[player] = nil end
 if s.Ready then s.Ready = false save(player, true) end
 sessions[player] = nil W.UpdatePlot(s.Plot, nil, nil)
end)
W.OnTerminal = function(player, index)
 local s = sessions[player]
 if not s or not s.Ready then return end
 send(player, s.Plot == index and "OPEN_MARKET" or "Cette entreprise appartient à un autre joueur.")
end
remote.OnServerEvent:Connect(function(player, action, value)
 local s = sessions[player]
 if not s or not s.Ready or s.Closing or type(action) ~= "string" then return end
 if os.clock() - s.LastAction < 0.15 then return end
 s.LastAction = os.clock()
 if action == "Ready" then send(player) return end
 if not studio and os.time() - s.LastSaved > 110 then send(player, "Sauvegarde en retard : achats suspendus pour protéger ta progression.") return end
 if value ~= nil and type(value) ~= "number" and type(value) ~= "string" then return end
 if type(value) == "number" and (value ~= value or value % 1 ~= 0 or math.abs(value) > 10) then return end
 if action == "Home" then
  if logistics:Busy(player) or carrier == player then send(player, "Dépose ce que tu portes avant de rentrer.") return end
  if player.Character then local hum = player.Character:FindFirstChildOfClass("Humanoid") if hum and hum.SeatPart then send(player, "Descends du véhicule avant de rentrer.") return end arrive(player, player.Character) end
  return
 end
 if action == "Drop" then if carrier == player then dropVIP() end logistics:Drop(player) return end
 if action == "Hire" then
  local ok, message = Staff.Hire(s.Data, value, E.OrderCost(s.Data))
  if ok then W.UpdatePlot(s.Plot, player, s.Data) end
  send(player, message) return
 end
 if action == "Manager" then
  if s.Data.Staff.Manager < 1 then send(player, "Recrute d'abord un gérant (niveau 4).") return end
  s.Data.ManagerEnabled = not s.Data.ManagerEnabled
  send(player, s.Data.ManagerEnabled and "Gérant actif : recrutement et formation, réserve de deux lots préservée." or "Gestion automatique suspendue.") return
 end
 if action == "Rivalry" then
  if not studio then send(player, "Le vol de colis reste désactivé hors Studio en attendant les tests de sauvegarde croisée.") return end
  if s.Data.Level < 2 or s.Data.Parcel or s.Data.Order then send(player, "Niveau 2 requis, sans livraison en cours.") return end
  s.Data.Rivalry = not s.Data.Rivalry send(player, s.Data.Rivalry and "Vol de colis activé entre volontaires. Assurance : 50 %." or "Colis protégés.") return
 end
 if action == "AutoOrder" and s.Data.Staff.Buyer < 1 then send(player, "Recrute un responsable commandes pour automatiser les achats.") return end
 if action == "Vehicle" and cars[player] and cars[player].Seat.Occupant then send(player, "Descends du véhicule avant de le remplacer.") return end
 if action == "Contribute" then
  local d = s.Data
  if cityEvent.Kind ~= "Commande collective" or cityEvent.Units >= cityEvent.Target then send(player, "Aucune commande collective ouverte.") return end
  if d.Product ~= cityEvent.Product or d.Stock < 1 then send(player, "Il faut du stock de " .. C.Products[cityEvent.Product].Name .. ".") return end
  local amount = 0
  local units = math.min(5, d.Stock, cityEvent.Target - cityEvent.Units)
  for _ = 1, units do amount += E.Sale(d, 1.5) P.OnSale(d, "Collective", os.time()) end
  cityEvent.Units += units
  send(player, "Contribution : " .. units .. " produits, +" .. amount .. " $. Merci !")
  return
 end
 local ok, message = P.Action(s.Data, action, value, os.time(), E.OrderCost(s.Data))
 if ok == nil then ok, message = E.Action(s.Data, action, value, os.clock()) end
 if ok then
  if action == "Order" then P.OnOrder(s.Data, os.time()) end
  if action == "Upgrade" or action == "Color" or action == "Luxury" or action == "Product" then W.UpdatePlot(s.Plot, player, s.Data) end
  if action == "Luxury" then W.ApplyPersonal(player, s.Data) end
  if action == "Vehicle" then
   if cars[player] then cars[player].Model:Destroy() end
   cars[player] = W.Car(s.Plot, value, player)
  end
 end
 send(player, message)
end)
local function invite(player, s, bonus, kind)
 customers:Invite(player, s, bonus, kind)
end
W.CheckIn = function(player, npc, bonus, kind)
 local s = sessions[player]
 if not valid(player) then return false end
 if not customers:CanJoin(s) then
  if os.clock() >= (s.NextQueueNotice or 0) then
   s.NextQueueNotice = os.clock() + 4
   send(player, "File pleine ou stock réservé aux clients présents : encaisse un client avant de déposer celui que tu portes.")
  end
  return false
 end
 Carry.Release(npc)
 customers:Admit(player, s, npc, bonus, kind)
 return true
end
local function checkout(player, s)
 if not s.Waiting or not s.Visitor or not s.Visitor.Parent then return false end
 local target = W.QueuePosition(s.Plot, 1)
 if (s.Visitor.PrimaryPart.Position - target).Magnitude > 5 then return false end
 local amount = E.Sale(s.Data, s.Waiting)
 if amount > 0 then
  P.OnSale(s.Data, s.WaitingKind, os.time())
  if s.WaitingKind == "Disputed" then s.SessionDisputed = (s.SessionDisputed or 0) + 1 end
 end
 customers:Served(player, s)
 send(player, amount > 0 and ("Client encaissé : +" .. amount .. " $ !") or "Plus de stock : le client repart.")
 return amount > 0
end
local seconds = 0
W.OnCashier = function(player, index)
 local s = sessions[player] local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not valid(player) or not root or s.Plot ~= index or (root.Position - (W.Plots[index].CF * CFrame.new(0, 2, 0)).Position).Magnitude > 12 then return end
 if not s.Waiting then send(player, "Aucun client à encaisser pour l'instant.") return end
 checkout(player, s)
end
task.spawn(function()
 while true do
  task.wait(1) seconds += 1
  local now = os.time()
  if now >= cityEvent.Ends then
   eventNumber += 1
   local kinds = {"Bus de touristes", "Commande collective", "Tendance surprise", "Préparation"}
   cityEvent = {Kind = kinds[(eventNumber - 1) % #kinds + 1], Product = (eventNumber - 1) % #C.Products + 1, Ends = now + 90, Units = 0, Target = 30}
   W.CityEvent(cityEvent)
   for player in pairs(sessions) do send(player, cityEvent.Kind .. " : " .. C.Products[cityEvent.Product].Name .. " ! Consulte les objectifs.") end
  end
  if os.clock() >= nextTrend then trend = trend % #C.Products + 1 nextTrend = os.clock() + 90 end
  if not vip and seconds % 25 == 0 then
   vip = W.Person(W.City, "ClientVIP", CFrame.new(0, 21, -125), Color3.fromRGB(239, 195, 83))
   local prompt = Instance.new("ProximityPrompt") prompt.ActionText, prompt.ObjectText, prompt.HoldDuration = "Accompagner", "Client VIP • vente x3", 0.5 prompt.MaxActivationDistance, prompt.RequiresLineOfSight, prompt.Parent = 10, false, vip.PrimaryPart
   prompt.Triggered:Connect(function(player)
    local s = sessions[player] local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not vip or carrier or logistics:Busy(player) or not s or not s.Ready or (not studio and os.time() - s.LastSaved > 110) or not root or (root.Position - vip.PrimaryPart.Position).Magnitude > 12 then return end
    if s.Data.Stock < 1 then send(player, "Il te faut du stock pour accueillir ce client.") return end
    Carry.new(player.Character, vip, "VIP"):Attach()
    carrier = player prompt.Enabled = false
    player.Character.Humanoid.WalkSpeed = 11
    send(player, "Ramène le VIP à ton comptoir : une vente à triple prix !")
   end)
  end
  if carrier then
   local root = carrier.Character and carrier.Character:FindFirstChild("HumanoidRootPart")
   local hum = carrier.Character and carrier.Character:FindFirstChildOfClass("Humanoid")
   local s = sessions[carrier]
   if not root or not hum or hum.Health <= 0 or hum.SeatPart or not s or (not studio and os.time() - s.LastSaved > 110) then dropVIP()
   else
    if (root.Position - W.Plots[s.Plot].CF.Position).Magnitude < 16 then
     if W.CheckIn(carrier, vip, 3, "VIP") then
      local player = carrier hum.WalkSpeed = 16 vip, carrier = nil, nil
      send(player, "VIP accueilli : il va attendre son encaissement au comptoir.")
     end
    end
   end
  end
  for player, s in pairs(sessions) do
   if not s.Ready or s.Closing then continue end
   if not studio and now - s.LastSaved > 110 then send(player, "Économie en pause : reconnexion à la sauvegarde en cours.") continue end
   local d = s.Data
   P.Init(d, now)
   Staff.Init(d)
   if d.Order then
    d.Order.Remaining = math.max(0, d.Order.Remaining - 1)
    if s.Delivery and (not s.Delivery.Model.Parent or os.clock() - s.Delivery.Started > 25) then
     s.Delivery.Model:Destroy() s.Delivery = nil
    end
    if d.Order.Remaining <= 0 and not s.Delivery then
     local order = d.Order
     local delivery = {Started = os.clock()}
     s.Delivery = delivery
     delivery.Model = W.Delivery(s.Plot, function()
      -- Keep the order durable until arrival. Old callbacks cannot deliver twice.
      if sessions[player] ~= s or s.Delivery ~= delivery or d.Order ~= order then return end
      s.Delivery = nil
      if not valid(player) then return end
      d.Parcel = {Units = 10, Quality = order.Quality, Product = order.Product or d.Product, Paid = order.Paid or 0}
      d.Order = nil
      logistics:Spawn(player, s)
      send(player, "Livraison déposée ! Ramène le colis dans ta boutique pour remplir le stock.")
     end)
     send(player, "La camionnette arrive. Le colis sera disponible après son arrêt et son déchargement.")
    end
   end
   local interval = d.PriceMode == 3 and 7 or d.PriceMode == 1 and 3 or 5
   interval = math.max(2, interval - math.max(0, d.Staff.Cashier - 1))
   customers:Prune(player, s)
   if s.Waiting and d.Staff.Cashier > 0 and os.clock() - s.ArrivedAt >= interval then checkout(player, s) end
   if seconds % interval == 0 and d.Stock > 0 then
    local bonus = cityEvent.Kind == "Tendance surprise" and d.Product == cityEvent.Product and 1.3 or 1
    invite(player, s, bonus, "Local")
   end
   if cityEvent.Kind == "Bus de touristes" and seconds % 3 == 0 and d.Product == cityEvent.Product and d.Stock > 0 then
    invite(player, s, 1.2, "Touriste")
   end
   if d.AutoOrder and d.Staff.Buyer > 0 and d.Stock <= 2 + d.Staff.Buyer and not d.Order and not d.Parcel then
    local ok = E.Action(d, "Order")
    if ok then P.OnOrder(d, now) end
   end
   if seconds % 20 == 0 and Staff.Manage(d, E.OrderCost(d)) then W.UpdatePlot(s.Plot, player, d) send(player, "Ton gérant a recruté ou formé un employé.") end
   if player:FindFirstChild("leaderstats") then player.leaderstats.Ventes.Value = d.Sales player.leaderstats.Entreprise.Value = d.Level end
   send(player)
  end
  logistics:Tick()
  -- One contested customer per server cycle, scored by product, quality and price.
  if seconds % 9 == 0 then
   local winner, score
   for player, s in pairs(sessions) do
    if s.Ready and s.Data.Stock > 0 and (studio or now - s.LastSaved <= 110) then
     local preference = (math.floor(seconds / 9) % 3)
     local candidate = math.random() + s.Data.Quality * (preference == 0 and 3 or 1) + (s.Data.Product == trend and (preference == 1 and 3 or 1) or 0) - s.Data.PriceMode * (preference == 2 and 1.3 or 0.35) + s.Data.Reputation / 100 + (s.Data.MarketingUntil > now and 0.8 or 0)
     if not score or candidate > score then winner, score = player, candidate end
    end
   end
   if winner then invite(winner, sessions[winner], 1.25, "Disputed") end
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
 for player, s in pairs(sessions) do if s.Ready then s.Ready = false remaining += 1 task.spawn(function() save(player, true) remaining -= 1 end) end end
 local deadline = os.clock() + 25 while remaining > 0 and os.clock() < deadline do task.wait(0.1) end
end)
print("[Be-a-CEO] Gameplay ready: 8 plots, MarketBridge, economy, personal purchases, vehicles and VIP.")
