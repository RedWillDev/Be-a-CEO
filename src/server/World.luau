local C = require(game.ReplicatedStorage.BeACEO.Config)
local W = {Plots = {}}
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
 local m = Instance.new("Model")
 m.Name = name
 local body = W.Part(m, "Body", Vector3.new(2, 2.5, 1), cf * CFrame.new(0, 3, 0), color)
 W.Part(m, "Head", Vector3.new(1.5, 1.5, 1.5), cf * CFrame.new(0, 5, 0), Color3.fromRGB(224, 178, 139))
 for _, x in ipairs({-0.55, 0.55}) do W.Part(m, "Leg", Vector3.new(0.8, 1.8, 0.9), cf * CFrame.new(x, 1, 0), dark) end
 m.PrimaryPart = body
 for _, p in ipairs(m:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end
 m.Parent = parent
 return m
end
function W.Build()
 local existing = workspace:FindFirstChild("CEOCity")
 if existing then existing:Destroy() end
 W.Plots = {}
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
 for x = -6, 6, 6 do p("Product", Vector3.new(3, 2, 2), x, 4.5, 1, C.Products[data and data.Product or 1].Color) end
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
function W.Car(index, tier, player)
 local plot = W.Plots[index]
 local cf = plot.CF * CFrame.new(26, 2, -8)
 local m = Instance.new("Model") m.Name = player.Name .. "_Vehicle"
 local color = C.Vehicles[tier].Color
 local body = W.Part(m, "Chassis", Vector3.new(6, 1.5, 10 + tier * 0.4), cf, color)
 W.Part(m, "Cabin", Vector3.new(4.6, 2, 4), cf * CFrame.new(0, 1.7, 0.6), dark)
 W.Part(m, "Windshield", Vector3.new(4.4, 1.6, 0.2), cf * CFrame.new(0, 1.7, -1.5), Color3.fromRGB(133, 191, 209), Enum.Material.Glass)
 for _, x in ipairs({-3, 3}) do
  for _, z in ipairs({-3, 3}) do
   local wheel = W.Part(m, "Wheel", Vector3.new(1.2, 2.4, 2.4), cf * CFrame.new(x, -0.5, z) * CFrame.Angles(0, 0, math.pi / 2), dark)
   wheel.Shape = Enum.PartType.Cylinder
  end
 end
 for _, x in ipairs({-2, 2}) do W.Part(m, "Headlight", Vector3.new(1, 0.5, 0.2), cf * CFrame.new(x, 0.2, -5 - tier * 0.2), cream, Enum.Material.Neon) end
 if tier >= 4 then W.Part(m, "Spoiler", Vector3.new(7, 0.4, 1.5), cf * CFrame.new(0, 1.5, 4.5), dark) end
 local seat = Instance.new("VehicleSeat")
 seat.Name, seat.Size, seat.CFrame = "Driver", Vector3.new(2, 1, 2), cf * CFrame.new(0, 2.8, 0)
 seat.Anchored, seat.Transparency, seat.Parent = true, 1, m
 seat:SetAttribute("OwnerId", player.UserId)
 m.PrimaryPart, m.Parent = body, W.City
 return {Model = m, Seat = seat, Tier = tier, Speed = 0}
end
return W
