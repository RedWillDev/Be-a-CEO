-- R6-style articulated characters, no external scripts or animation asset dependency.
local CollectionService = game:GetService("CollectionService")
local Characters = {}
local skins = {Color3.fromRGB(221, 174, 130), Color3.fromRGB(146, 95, 65), Color3.fromRGB(244, 207, 172), Color3.fromRGB(92, 63, 49)}
local serial = 0
function Characters.Create(parent, name, cf, color)
 serial += 1
 local model = Instance.new("Model") model.Name = name
 local skin = skins[(serial - 1) % #skins + 1]
 local function part(n, size, offset, tint)
  local p = Instance.new("Part") p.Name, p.Size, p.CFrame, p.Color = n, size, cf * CFrame.new(offset), tint
  p.CanCollide, p.CanTouch, p.Massless = false, false, true
  p.TopSurface, p.BottomSurface, p.Parent = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth, model
  return p
 end
 local root = part("HumanoidRootPart", Vector3.new(2, 2, 1), Vector3.new(0, 3, 0), color)
 root.Anchored, root.Transparency = true, 1
 local torso = part("Torso", Vector3.new(2, 2, 1), Vector3.new(0, 3, 0), color)
 local head = part("Head", Vector3.new(1.35, 1.35, 1.35), Vector3.new(0, 4.65, 0), skin)
 local mesh = Instance.new("SpecialMesh") mesh.MeshType, mesh.Scale, mesh.Parent = Enum.MeshType.Head, Vector3.new(1, 1, 1), head
 local leftArm = part("Left Arm", Vector3.new(1, 2, 1), Vector3.new(-1.5, 3, 0), color)
 local rightArm = part("Right Arm", Vector3.new(1, 2, 1), Vector3.new(1.5, 3, 0), color)
 local pants = Color3.fromRGB(37 + serial % 3 * 12, 49, 66)
 local leftLeg = part("Left Leg", Vector3.new(1, 2, 1), Vector3.new(-0.5, 1, 0), pants)
 local rightLeg = part("Right Leg", Vector3.new(1, 2, 1), Vector3.new(0.5, 1, 0), pants)
 local function joint(n, a, b, c0, c1)
  local j = Instance.new("Motor6D") j.Name, j.Part0, j.Part1, j.C0, j.C1, j.Parent = n, a, b, c0, c1, a
 end
 joint("RootJoint", root, torso, CFrame.new(), CFrame.new())
 joint("Neck", torso, head, CFrame.new(0, 1, 0), CFrame.new(0, -0.65, 0))
 joint("Left Shoulder", torso, leftArm, CFrame.new(-1, 0.5, 0), CFrame.new(0.5, 0.5, 0))
 joint("Right Shoulder", torso, rightArm, CFrame.new(1, 0.5, 0), CFrame.new(-0.5, 0.5, 0))
 joint("Left Hip", torso, leftLeg, CFrame.new(-0.5, -1, 0), CFrame.new(0, 1, 0))
 joint("Right Hip", torso, rightLeg, CFrame.new(0.5, -1, 0), CFrame.new(0, 1, 0))
 local function detail(n, size, attached, offset, tint)
  local p = part(n, size, Vector3.zero, tint) p.CFrame = attached.CFrame * offset
  local weld = Instance.new("WeldConstraint") weld.Part0, weld.Part1, weld.Parent = attached, p, p
  return p
 end
 for _, x in ipairs({-0.23, 0.23}) do
  local eye = detail("Eye", Vector3.new(0.12, 0.16, 0.07), head, CFrame.new(x, 0.08, -0.66), Color3.fromRGB(25, 25, 30))
  eye.Shape = Enum.PartType.Ball
 end
 detail("Smile", Vector3.new(0.32, 0.055, 0.07), head, CFrame.new(0, -0.26, -0.66), Color3.fromRGB(83, 43, 36))
 detail("Hair", Vector3.new(1.4, 0.32, 1.36), head, CFrame.new(0, 0.62, 0.02), Color3.fromRGB(45 + serial % 4 * 18, 35, 27))
 for _, limb in ipairs({leftArm, rightArm}) do detail("Hand", Vector3.new(0.9, 0.45, 0.93), limb, CFrame.new(0, -0.8, 0), skin) end
 for _, limb in ipairs({leftLeg, rightLeg}) do detail("Shoe", Vector3.new(1.02, 0.4, 1.2), limb, CFrame.new(0, -0.85, -0.1), Color3.fromRGB(23, 27, 32)) end
 detail("Collar", Vector3.new(0.65, 0.18, 0.12), torso, CFrame.new(0, 0.85, -0.53), Color3.fromRGB(236, 234, 222))
 if name == "Touriste" then
  detail("HatBrim", Vector3.new(1.9, 0.12, 1.9), head, CFrame.new(0, 0.75, 0), Color3.fromRGB(221, 196, 135))
  detail("HatCrown", Vector3.new(1.3, 0.45, 1.3), head, CFrame.new(0, 1, 0), Color3.fromRGB(221, 196, 135))
  detail("Backpack", Vector3.new(1.35, 1.45, 0.7), torso, CFrame.new(0, -0.1, 0.8), Color3.fromRGB(162, 88, 55))
 elseif name == "Manager" or name == "ClientVIP" then
  detail("Tie", Vector3.new(0.25, 1.2, 0.1), torso, CFrame.new(0, 0.1, -0.56), Color3.fromRGB(236, 187, 80))
 elseif name == "Cashier" or name == "Receiver" or name == "Buyer" then
  detail("Badge", Vector3.new(0.45, 0.3, 0.1), torso, CFrame.new(0.5, 0.45, -0.56), Color3.fromRGB(245, 244, 231))
 end
 local hum = Instance.new("Humanoid") hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None hum.BreakJointsOnDeath = false hum.Parent = model
 model.PrimaryPart, model.Parent = root, parent
 model:SetAttribute("VisualSeed", serial)
 CollectionService:AddTag(model, "CEONPC")
 return model
end
return Characters
