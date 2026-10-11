local V = {}
local black = Color3.fromRGB(24, 30, 39)
local rubber = Color3.fromRGB(20, 22, 25)
local silver = Color3.fromRGB(175, 186, 196)
local glass = Color3.fromRGB(117, 173, 193)
function V.Build(parent, cf, kind, tier, color, makePart)
 local m = Instance.new("Model") m.Name, m.Parent = kind, parent
 local bus, van = kind == "TourBus", kind == "DeliveryVan"
 local width = bus and 8.5 or van and 7 or 6
 local length = bus and 24 or van and 15 or 10 + tier * 0.4
 local cabinHeight = bus and 5.3 or van and 3.6 or (tier >= 4 and 1.8 or 2.2)
 local function p(n, size, offset, tint, material)
  return makePart(m, n, size, cf * offset, tint, material)
 end
 local root = p("Chassis", Vector3.new(width, 1.3, length), CFrame.new(), color, Enum.Material.Metal)
 m.PrimaryPart = root
 p("LowerSill", Vector3.new(width - 0.2, 0.35, length - 0.3), CFrame.new(0, -0.75, 0), black)
 local cabinLength = bus and 21 or van and 5 or 4.6
 local cabinZ = van and -4 or bus and 0 or 0.5
 p("Roof", Vector3.new(width - 0.8, 0.25, cabinLength), CFrame.new(0, cabinHeight + 0.7, cabinZ), color)
 for _, x in ipairs({-1, 1}) do
  p("RoofRail", Vector3.new(0.25, 0.2, cabinLength - 0.6), CFrame.new(x * (width / 2 - 0.65), cabinHeight + 0.9, cabinZ), silver, Enum.Material.Metal)
  for _, z in ipairs({-1, 1}) do
   p("Pillar", Vector3.new(0.3, cabinHeight, 0.3), CFrame.new(x * (width / 2 - 0.55), cabinHeight / 2 + 0.6, cabinZ + z * (cabinLength / 2 - 0.2)), color)
  end
  p("SideGlass", Vector3.new(0.12, cabinHeight - 0.6, cabinLength - 0.7), CFrame.new(x * (width / 2 - 0.55), cabinHeight / 2 + 0.7, cabinZ), glass, Enum.Material.Glass).Transparency = 0.3
  p("MirrorArm", Vector3.new(0.7, 0.15, 0.2), CFrame.new(x * (width / 2 + 0.15), 1.3, -length / 2 + 2.5), black)
  p("Mirror", Vector3.new(0.45, 0.6, 0.8), CFrame.new(x * (width / 2 + 0.5), 1.4, -length / 2 + 2.5), color)
  p("DoorHandle", Vector3.new(0.12, 0.17, 0.65), CFrame.new(x * (width / 2 + 0.02), 0.25, cabinZ + 1), silver)
 end
 for _, z in ipairs({-1, 1}) do
  p("Windscreen", Vector3.new(width - 1.2, cabinHeight - 0.3, 0.15), CFrame.new(0, cabinHeight / 2 + 0.65, cabinZ + z * (cabinLength / 2 - 0.15)), glass, Enum.Material.Glass).Transparency = 0.28
  p("Bumper", Vector3.new(width + 0.1, 0.4, 0.4), CFrame.new(0, -0.4, z * length / 2), black)
  p("LicensePlate", Vector3.new(1.5, 0.4, 0.1), CFrame.new(0, -0.05, z * (length / 2 + 0.22)), Color3.fromRGB(234, 231, 216))
  for _, x in ipairs({-1, 1}) do
   p(z == -1 and "Headlight" or "TailLight", Vector3.new(1.2, 0.35, 0.15), CFrame.new(x * (width / 2 - 1), 0.3, z * (length / 2 + 0.1)), z == -1 and Color3.fromRGB(239, 245, 218) or Color3.fromRGB(224, 63, 53), Enum.Material.Neon)
  end
 end
 p("FrontGrille", Vector3.new(width * 0.48, 0.5, 0.16), CFrame.new(0, 0.3, -length / 2 - 0.05), black)
 for x = -1, 1, 0.5 do p("GrilleChrome", Vector3.new(0.07, 0.4, 0.1), CFrame.new(x, 0.3, -length / 2 - 0.15), silver) end
 for _, x in ipairs({-1, 1}) do
  for _, z in ipairs({-1, 1}) do
   local wheelCF = CFrame.new(x * width / 2, -0.55, z * (length / 2 - 2))
   local tire = p("Tire", Vector3.new(0.75, 2.35, 2.35), wheelCF, rubber)
   tire.Shape = Enum.PartType.Cylinder
   local rim = p("AlloyRim", Vector3.new(0.8, 1.55, 1.55), wheelCF, silver, Enum.Material.Metal) rim.Shape = Enum.PartType.Cylinder
   local hub = p("WheelHub", Vector3.new(0.86, 0.45, 0.45), wheelCF, black) hub.Shape = Enum.PartType.Cylinder
   for angle = 0, 4 do
    p("WheelSpoke", Vector3.new(0.84, 1.3, 0.12), wheelCF * CFrame.Angles(angle * math.pi / 5, 0, 0), black)
   end
  end
 end
 local rows = bus and 5 or 1
 for row = 1, rows do
  for _, x in ipairs({-1, 1}) do
   local z = bus and -7 + row * 3.2 or cabinZ + 0.4
   p("SeatCushion", Vector3.new(1.6, 0.3, 1.5), CFrame.new(x * 1.6, 0.9, z), black)
   p("SeatBack", Vector3.new(1.6, 1.6, 0.35), CFrame.new(x * 1.6, 1.7, z + 0.7), black)
  end
 end
 p("Dashboard", Vector3.new(width - 1, 0.45, 0.8), CFrame.new(0, 1.1, cabinZ - cabinLength / 2 + 0.5), black)
 local steering = p("SteeringWheel", Vector3.new(0.15, 0.85, 0.85), CFrame.new(-1.4, 1.6, cabinZ - cabinLength / 2 + 1.1) * CFrame.Angles(0, math.pi / 2, 0), black) steering.Shape = Enum.PartType.Cylinder
 if bus then
  for z = -8, 8, 4 do
   for _, x in ipairs({-1, 1}) do p("WindowDivider", Vector3.new(0.25, cabinHeight, 0.2), CFrame.new(x * (width / 2 - 0.5), cabinHeight / 2 + 0.6, z), color) end
  end
  p("DestinationPanel", Vector3.new(width - 1, 0.75, 0.2), CFrame.new(0, cabinHeight + 0.15, -cabinLength / 2), black)
  p("AirConditioner", Vector3.new(4, 0.7, 6), CFrame.new(0, cabinHeight + 1.1, 3), silver)
  p("DoorStep", Vector3.new(1, 0.3, 3), CFrame.new(width / 2, -0.5, -7), silver)
 elseif van then
  p("CargoBox", Vector3.new(width - 0.3, 4.1, 8), CFrame.new(0, 2.3, 3.3), color)
  p("RearDoorSeam", Vector3.new(0.1, 3.8, 0.1), CFrame.new(0, 2.3, length / 2 + 0.05), black)
  for _, x in ipairs({-1, 1}) do p("RearDoorHandle", Vector3.new(0.12, 0.65, 0.2), CFrame.new(x * 0.4, 2, length / 2 + 0.12), silver) end
 else
  local hood = Instance.new("WedgePart") hood.Name, hood.Size, hood.CFrame, hood.Color = "SculptedHood", Vector3.new(width - 0.2, 0.5, 2.6), cf * CFrame.new(0, 0.85, -length / 2 + 1.3) * CFrame.Angles(0, math.pi, 0), color
  hood.Anchored, hood.Parent = true, m
  if tier >= 3 then for _, x in ipairs({-1, 1}) do p("Exhaust", Vector3.new(0.6, 0.4, 0.8), CFrame.new(x * 1.8, -0.65, length / 2), silver, Enum.Material.Metal) end end
  if tier >= 4 then
   for _, x in ipairs({-1, 1}) do p("SpoilerMount", Vector3.new(0.2, 0.7, 0.4), CFrame.new(x * 2, 1, length / 2 - 0.6), black) end
   p("RearWing", Vector3.new(width + 0.5, 0.2, 1), CFrame.new(0, 1.45, length / 2 - 0.6), black)
  end
 end
 return m
end
return V
