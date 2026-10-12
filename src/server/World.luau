local C = require(game.ReplicatedStorage.BeACEO.Config)
local Characters = require(script.Parent.Characters)
local VehicleArt = require(script.Parent.VehicleArt)
local TweenService = game:GetService("TweenService")
local W = {Plots = {}}
local walkers = {}
local pedestrians = {}
local walkClock = 0
game:GetService("RunService").Heartbeat:Connect(function(dt)
 walkClock += dt if walkClock < 0.1 then return end
 local step = math.min(walkClock, 0.2) walkClock = 0
 for model, route in pairs(walkers) do
  if not model.Parent then walkers[model] = nil continue end
  if model:GetAttribute("Carried") then continue end
  local hum = model:FindFirstChildOfClass("Humanoid")
  local goal = route.Points[route.Index]
  local delta = goal - model.PrimaryPart.Position
  local distance = Vector3.new(delta.X, 0, delta.Z).Magnitude
  if hum.Health <= 0 or os.clock() > route.Deadline then
   walkers[model] = nil hum:Move(Vector3.zero)
   if route.Done then task.defer(route.Done, false) end
   if not route.Done and hum.Health > 0 then
    route.Index = route.Index % #route.Points + 1 route.Deadline = os.clock() + 65 walkers[model] = route
   end
  elseif distance < 1.6 then
   hum:Move(Vector3.zero)
   route.Wait -= step
   if route.Wait <= 0 then
    if route.Done and route.Index == #route.Points then
     walkers[model] = nil task.defer(route.Done, true)
    else
     route.Index = route.Index % #route.Points + 1 route.Wait = route.Pause route.Deadline = os.clock() + 65
    end
   end
  else
   hum.WalkSpeed = route.Speed
   hum:MoveTo(goal)
  end
 end
end)
function W.Wander(model, points, speed, pause)
 walkers[model] = {Points = points, Speed = speed or 7, Pause = pause or 2, Wait = pause or 2, Index = 1, Deadline = os.clock() + 60}
end
function W.TouristWalk(model)
 local z = model.PrimaryPart.Position.Z < 0 and -31 or 31
 W.Wander(model, {Vector3.new(-155, 23.7, z), Vector3.new(155, 23.7, z)}, 6.5, 1.5)
end
function W.Route(model, points, done, speed)
 W.Wander(model, points, speed or 8, 0)
 walkers[model].Done = done
end
function W.StopRoute(model)
 walkers[model] = nil
 local hum = model:FindFirstChildOfClass("Humanoid")
 if hum then hum:Move(Vector3.zero) hum:MoveTo(model.PrimaryPart.Position) end
end
function W.ReleaseCustomer(model, index)
 if not model or not model.Parent then return end
 local cf = W.Plots[index].CF
 local z = index <= 4 and -31 or 31
 local function resume()
  if not model.Parent then return end
  if not pedestrians[model] then model:Destroy() return end
  model:SetAttribute("Shopping", false)
  W.Wander(model, {Vector3.new(-155, 23.7, z), Vector3.new(155, 23.7, z)}, 7, 1)
 end
 W.Route(model, {(cf * CFrame.new(-8, 3.5, -5)).Position, (cf * CFrame.new(-8, 3, -19)).Position, Vector3.new(cf.X - 8, 23.7, z)}, resume)
end
function W.QueuePosition(index, slot)
 return (W.Plots[index].CF * CFrame.new(5, 3.5, -3.5 - (slot - 1) * 4)).Position
end
function W.FaceQueue(model, index)
 local position = model.PrimaryPart.Position
 local forward = W.Plots[index].CF:VectorToWorldSpace(Vector3.new(0, 0, 1))
 model:PivotTo(CFrame.lookAt(position, position + forward))
end
function W.Visit(index, arrived, slot)
 local cf = W.Plots[index].CF
 local z = index <= 4 and -31 or 31
 local candidate, best
 for model in pairs(pedestrians) do
  if not model.Parent then pedestrians[model] = nil
  elseif not model:GetAttribute("Shopping") and not model:GetAttribute("Carried") and model.PrimaryPart.Position.Z * z > 0 then
   local distance = math.abs(model.PrimaryPart.Position.X - cf.X)
   if not best or distance < best then candidate, best = model, distance end
  end
 end
 if not candidate then return nil end
 candidate:SetAttribute("Shopping", true)
 W.Route(candidate, {Vector3.new(cf.X, 23.7, z), (cf * CFrame.new(5, 3, -19)).Position, W.QueuePosition(index, slot or 1)}, function(reached)
  arrived(candidate, reached)
 end)
 return candidate
end
function W.MoveVehicle(model, destination, duration, finished)
 local value = Instance.new("CFrameValue") value.Value = model:GetPivot()
 local changed = value.Changed:Connect(function(cf) if model.Parent then model:PivotTo(cf) end end)
 local tween = TweenService:Create(value, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Value = destination})
 tween.Completed:Once(function() changed:Disconnect() value:Destroy() if model.Parent and finished then finished() end end)
 tween:Play()
end
local dark = Color3.fromRGB(29, 40, 53)
local cream = Color3.fromRGB(224, 223, 210)
function W.Part(parent, name, size, cf, color, material)
 local p = Instance.new("Part")
 p.Name, p.Size, p.CFrame, p.Color = name, size, cf, color
 p.Anchored = true
 p.Material = material or Enum.Material.SmoothPlastic
 p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
 p.Parent = parent
 return p
end
function W.Sign(parent, text, cf, size, color)
 local p = W.Part(parent, "Sign", size or Vector3.new(22, 4, 0.3), cf, dark)
 local gui = Instance.new("SurfaceGui")
 gui.Face, gui.SizingMode, gui.PixelsPerStud = Enum.NormalId.Front, Enum.SurfaceGuiSizingMode.PixelsPerStud, 30
 gui.Parent = p
 local label = Instance.new("TextLabel")
 label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
 label.Text, label.TextScaled, label.Font = text, true, Enum.Font.GothamBold
 label.TextColor3 = color or Color3.fromRGB(241, 239, 227)
 label.Parent = gui
 return p
end
function W.Person(parent, name, cf, color)
 return Characters.Create(parent, name, cf, color)
end
function W.Build()
 local existing = workspace:FindFirstChild("CEOCity")
 if existing then existing:Destroy() end
 W.Plots = {}
 walkers = {}
 pedestrians = {}
 local city = Instance.new("Model")
 city.Name = "CEOCity"
 city.Parent = workspace
 W.City = city
 -- Raised above the original baseplate; all generated content belongs to CEOCity.
 W.Part(city, "Island", Vector3.new(390, 4, 300), CFrame.new(0, 18, 0), Color3.fromRGB(95, 129, 113))
 W.Part(city, "Boulevard", Vector3.new(360, 0.3, 45), CFrame.new(0, 20.1, 0), dark, Enum.Material.Asphalt)
 for x = -170, 170, 18 do W.Part(city, "RoadLine", Vector3.new(8, 0.05, 0.5), CFrame.new(x, 20.3, 0), cream) end
 for _, z in ipairs({-29, 29}) do
  W.Part(city, "Sidewalk", Vector3.new(360, 0.7, 12), CFrame.new(0, 20.35, z), cream, Enum.Material.Concrete)
  for x = -175, 175, 50 do
   W.Part(city, "Lamp", Vector3.new(0.5, 13, 0.5), CFrame.new(x, 27, z), dark)
   local light = W.Part(city, "Light", Vector3.new(3, 0.5, 3), CFrame.new(x, 33.5, z), Color3.fromRGB(255, 234, 186), Enum.Material.Neon)
   local lamp = Instance.new("PointLight") lamp.Brightness, lamp.Range, lamp.Parent = 1, 23, light
  end
 end
 for i = 1, 8 do
  local side = i <= 4 and -1 or 1
  local x = -120 + ((i - 1) % 4) * 80
  local cf = CFrame.new(x, 20.5, side * 67) * CFrame.Angles(0, side == 1 and 0 or math.pi, 0)
  local plot = {CF = cf, Index = i}
  W.Plots[i] = plot
  W.Part(city, "Parcel" .. i, Vector3.new(66, 0.5, 57), cf, Color3.fromRGB(196, 200, 190), Enum.Material.Concrete)
  W.UpdatePlot(i, nil, nil)
  task.wait()
 end
 W.Part(city, "Plaza", Vector3.new(72, 0.6, 48), CFrame.new(0, 20.5, -125), cream)
 W.Sign(city, "BE A CEO  /  MARKET DISTRICT", CFrame.new(0, 30, -144), Vector3.new(60, 6, 1), C.Palette[1])
 W.Sign(city, "PLACE DES OPPORTUNITÉS\nClient VIP • bonus de vente", CFrame.new(0, 24, -105) * CFrame.Angles(0, math.pi, 0), Vector3.new(35, 4, 0.5))
 for _, x in ipairs({-170, 170}) do
  for z = -110, 110, 44 do
   W.Part(city, "Trunk", Vector3.new(2, 9, 2), CFrame.new(x, 25, z), Color3.fromRGB(109, 82, 63), Enum.Material.Wood)
   local tree = W.Part(city, "Canopy", Vector3.new(12, 12, 12), CFrame.new(x, 34, z), Color3.fromRGB(59, 111, 87))
   tree.Shape = Enum.PartType.Ball
  end
 end
 local spawn = Instance.new("SpawnLocation")
 spawn.Name, spawn.Anchored, spawn.Neutral = "CityArrival", true, true
 spawn.Size, spawn.CFrame, spawn.Transparency = Vector3.new(8, 1, 8), CFrame.new(0, 21, 20), 1
 spawn.Parent = city
 game.Lighting.ClockTime = 15
 game.Lighting.Brightness = 2
 game.Lighting.Ambient = Color3.fromRGB(133, 144, 157)
 for i = 1, 36 do
  local z = i % 2 == 0 and 31 or -31
  local x = -153 + math.floor((i - 1) / 2) * 18
  local person = W.Person(city, "Passant", CFrame.new(x, 20.7, z), C.Palette[(i - 1) % 4 + 1])
  pedestrians[person] = true
  W.Wander(person, {Vector3.new(i % 3 == 0 and -155 or 155, 23.7, z), Vector3.new(i % 3 == 0 and 155 or -155, 23.7, z)}, 6 + i % 3, 1)
 end
 return city
end
function W.UpdatePlot(index, player, data)
 local plot = W.Plots[index]
 if plot.Model then plot.Model:Destroy() end
 local m = Instance.new("Model") m.Name = "Company" .. index m.Parent = W.City plot.Model = m
 local cf = plot.CF
 local level = data and data.Level or 1
 local color = C.Palette[data and data.Color or ((index - 1) % 4 + 1)]
 local function p(n, s, x, y, z, c, mat) return W.Part(m, n, s, cf * CFrame.new(x, y, z), c, mat) end
 p("Floor", Vector3.new(37, 0.5, 29), 0, 0.5, 2, cream)
 p("Back", Vector3.new(38, 11, 1), 0, 6, 16, dark)
 for _, x in ipairs({-19, 19}) do p("Wall", Vector3.new(1, 11, 29), x, 6, 2, cream) end
 p("Roof", Vector3.new(40, 1, 32), 0, 12, 2, dark)
 p("Counter", Vector3.new(18, 3, 3), 0, 2, 1, color)
 local register = p("CashRegister", Vector3.new(2, 1, 2), 5, 4, 1, dark)
 local checkout = Instance.new("ProximityPrompt")
 checkout.ActionText, checkout.ObjectText, checkout.HoldDuration = "Encaisser", "Caisse", 0.4
 checkout.MaxActivationDistance, checkout.RequiresLineOfSight, checkout.Parent = 10, false, register
 checkout.Triggered:Connect(function(ply) if W.OnCashier then W.OnCashier(ply, index) end end)
 if data and data.Staff then
  local roles = {"Cashier", "Receiver", "Buyer", "Manager"}
  for i, role in ipairs(roles) do
   if (data.Staff[role] or 0) > 0 then
    if role == "Cashier" then
     -- Register is at local (5, 4, 1); stand behind it facing the shop entrance.
     local employee = W.Person(m, role, cf * CFrame.new(5, 0.75, 4.5), color)
     employee.Humanoid.WalkSpeed, employee.Humanoid.AutoRotate = 0, false
     employee.PrimaryPart.Anchored = true
     employee:SetAttribute("Stationary", true)
    elseif role == "Receiver" then
     local employee = W.Person(m, role, cf * CFrame.new(13, 0.75, -7), C.Palette[i])
     employee:SetAttribute("ReceiverStatus", "Disponible")
     local badge = Instance.new("BillboardGui") badge.Name = "ReceiverTask"
     badge.Size, badge.StudsOffset, badge.AlwaysOnTop, badge.Parent = UDim2.fromOffset(190, 42), Vector3.new(0, 3.5, 0), true, employee.PrimaryPart
     local label = Instance.new("TextLabel") label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
     label.TextSize, label.TextColor3, label.Parent = 14, Color3.fromRGB(255, 218, 149), badge
     local function status() label.Text = "RÉCEPTION\n" .. (employee:GetAttribute("ReceiverStatus") or "Disponible") end
     employee:GetAttributeChangedSignal("ReceiverStatus"):Connect(status) status()
    else
     local employee = W.Person(m, role, cf * CFrame.new(-14 + i * 6, 0.5, 8), C.Palette[i])
     W.Wander(employee, {(cf * CFrame.new(-16 + i * 6, 3.5, 8)).Position, (cf * CFrame.new(-12 + i * 6, 3.5, 10)).Position}, 2.5, 4)
    end
   end
  end
 end
 for x = -6, 6, 6 do
  local product = data and data.Product or 1
  local productColor = C.Products[product].Color
  if product == 1 then
   p("ShoeSole", Vector3.new(2, 0.3, 3), x, 3.8, 1, cream)
   p("ShoeUpper", Vector3.new(1.8, 0.9, 2.7), x, 4.4, 1, productColor)
   p("ShoeHeel", Vector3.new(1.8, 0.8, 0.8), x, 5, 2, productColor)
  elseif product == 2 then
   for _, offset in ipairs({-1, 1}) do p("EarCup", Vector3.new(0.6, 1.8, 1), x + offset, 4.8, 1, productColor) end
   p("Headband", Vector3.new(2.5, 0.4, 0.7), x, 5.8, 1, dark)
  else
   p("ToyBody", Vector3.new(1.3, 1.5, 1), x, 4.5, 1, productColor)
   local head = p("ToyHead", Vector3.new(1.2, 1.2, 1.2), x, 5.8, 1, productColor) head.Shape = Enum.PartType.Ball
  end
 end
 for floor = 2, level do
  p("UpperFloor", Vector3.new(38, 9, 29), 0, 12 + (floor - 1) * 9 - 4, 2, dark)
  p("Accent", Vector3.new(40, 0.7, 31), 0, 12 + (floor - 1) * 9, 2, color)
  for x = -14, 14, 7 do p("Window", Vector3.new(4.7, 5, 0.3), x, 12 + (floor - 1) * 9 - 4, -12.7, Color3.fromRGB(134, 184, 200), Enum.Material.Glass) end
 end
 local title = player and (player.DisplayName .. " • " .. C.Levels[level].Name) or ("PARCELLE " .. index .. " / DISPONIBLE")
 W.Sign(m, title, cf * CFrame.new(0, 10, -14.3), Vector3.new(36, 3, 0.5), color)
 if data then
  for id, owned in pairs(data.Luxuries) do
   if owned then
    local n = tonumber(id)
    local gold = Color3.fromRGB(238, 194, 91)
    if n == 1 then
     p("WatchDisplay", Vector3.new(3, 1.5, 3), 12, 1.3, 5, dark)
     p("WatchFace", Vector3.new(1.5, 0.3, 1.5), 12, 2.2, 5, gold)
    elseif n == 2 then
     p("SofaSeat", Vector3.new(8, 1.5, 3), 11, 1.5, 9, color)
     p("SofaBack", Vector3.new(8, 3.5, 1), 11, 2.5, 11, color)
     for _, x in ipairs({7, 15}) do p("SofaArm", Vector3.new(1, 2.5, 4), x, 2, 9.5, color) end
     p("CoffeeTable", Vector3.new(6, 1, 2), 11, 1.5, 5, dark)
    else
     p("SculpturePlinth", Vector3.new(4, 1, 4), -12, 1, 9, dark)
     local sculpture = p("SignatureSculpture", Vector3.new(3, 6, 3), -12, 4.5, 9, gold, Enum.Material.Metal)
     sculpture.CFrame *= CFrame.Angles(0, math.pi / 4, math.pi / 8)
    end
    W.Sign(m, C.Luxuries[n].Name, cf * CFrame.new(12, 4, 9 - n * 5), Vector3.new(9, 1.5, 0.2))
   end
  end
 end
 local terminal = p("MarketBridge", Vector3.new(4, 3, 1), -12, 3, -8, dark)
 local prompt = Instance.new("ProximityPrompt")
 prompt.ActionText, prompt.ObjectText, prompt.MaxActivationDistance = "Gérer mon entreprise", "MarketBridge", 12
 prompt.RequiresLineOfSight = false prompt.Parent = terminal
 prompt.Triggered:Connect(function(ply) if W.OnTerminal then W.OnTerminal(ply, index) end end)
 return m
end
function W.ApplyPersonal(player, data)
 local character = player.Character
 if not character or not data.Luxuries["1"] then return end
 local hand = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")
 if not hand or character:FindFirstChild("CEOWatch") then return end
 local watch = W.Part(character, "CEOWatch", Vector3.new(0.55, 0.25, 0.6), hand.CFrame * CFrame.new(0, 0.15, -0.4), Color3.fromRGB(238, 194, 91), Enum.Material.Metal)
 watch.Anchored, watch.CanCollide, watch.Massless = false, false, true
 local weld = Instance.new("WeldConstraint") weld.Part0, weld.Part1, weld.Parent = hand, watch, watch
end
function W.CityEvent(event)
 if W.EventModel then W.EventModel:Destroy() end
 local m = Instance.new("Model") m.Name, m.Parent = "CityEvent", W.City W.EventModel = m
 local color = C.Products[event.Product].Color
 W.Sign(m, event.Kind .. "\n" .. C.Products[event.Product].Name, CFrame.new(0, 27, -109) * CFrame.Angles(0, math.pi, 0), Vector3.new(36, 5, 0.6), color)
 if event.Kind == "Bus de touristes" then
  local cf = CFrame.new(0, 22, -14) * CFrame.Angles(0, math.pi / 2, 0)
  local bus = VehicleArt.Build(m, cf + Vector3.new(160, 0, 0), "TourBus", 1, color, W.Part)
  W.Sign(bus, "CITY TOURS", bus:GetPivot() * CFrame.new(0, 5.45, -10.7), Vector3.new(6, 0.65, 0.1))
  W.MoveVehicle(bus, cf, 7, function()
   for i = 1, 6 do
    local tourist = W.Person(m, "Touriste", CFrame.new(-10 + i * 3, 20.7, -33), C.Palette[(i - 1) % 4 + 1])
    W.TouristWalk(tourist)
    if W.OnTourist then W.OnTourist(tourist) end
   end
  end)
 elseif event.Kind == "Commande collective" then
  for i = 1, 6 do W.Part(m, "Cargo", Vector3.new(3, 3, 3), CFrame.new(-10 + i * 3, 22.5, -117), Color3.fromRGB(177, 127, 76), Enum.Material.Wood) end
 end
end
function W.Delivery(index)
 local plot = W.Plots[index]
 local cf = CFrame.new(plot.CF.X, 22, index <= 4 and -14 or 14) * CFrame.Angles(0, index <= 4 and math.pi / 2 or -math.pi / 2, 0)
 local m = VehicleArt.Build(W.City, cf, "DeliveryVan", 1, cream, W.Part)
 W.Sign(m, "MARKETBRIDGE", cf * CFrame.new(0, 3, 7.65) * CFrame.Angles(0, math.pi, 0), Vector3.new(5.5, 1, 0.1), C.Palette[1])
 task.delay(5, function() if m.Parent then W.MoveVehicle(m, cf * CFrame.new(0, 0, -70), 5, function() m:Destroy() end) end end)
end
function W.Car(index, tier, player)
 local plot = W.Plots[index]
 local cf = plot.CF * CFrame.new(26, 2, -8)
 local color = C.Vehicles[tier].Color
 local m = VehicleArt.Build(W.City, cf, "Car", tier, color, W.Part) m.Name = player.Name .. "_Vehicle"
 local seat = Instance.new("VehicleSeat")
 seat.Name, seat.Size, seat.CFrame = "Driver", Vector3.new(2, 1, 2), cf * CFrame.new(0, 2.8, 0)
 seat.Anchored, seat.Transparency, seat.Parent = true, 1, m
 seat:SetAttribute("OwnerId", player.UserId)
 return {Model = m, Seat = seat, Tier = tier, Speed = 0}
end
return W
