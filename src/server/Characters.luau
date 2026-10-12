-- Standard Roblox R6 characters, with a local fallback and role-specific outfits.
local CollectionService = game:GetService("CollectionService")
local Characters = {}
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
pcall(function() PhysicsService:RegisterCollisionGroup("CEONPC") end)
PhysicsService:CollisionGroupSetCollidable("CEONPC", "CEONPC", false)
local description = Instance.new("HumanoidDescription")
local success, template = pcall(function()
 return Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R6)
end)
description:Destroy()
if not success then warn("[NPC] Roblox avatar unavailable; using local R6 fallback: " .. tostring(template)) template = nil end
local skins = {Color3.fromRGB(221, 174, 130), Color3.fromRGB(146, 95, 65), Color3.fromRGB(244, 207, 172), Color3.fromRGB(92, 63, 49), Color3.fromRGB(185, 133, 94), Color3.fromRGB(116, 76, 56)}
local outfits = {Color3.fromRGB(213, 64, 64), Color3.fromRGB(57, 114, 219), Color3.fromRGB(241, 241, 231), Color3.fromRGB(234, 184, 54), Color3.fromRGB(68, 164, 107), Color3.fromRGB(153, 94, 198), Color3.fromRGB(232, 125, 62), Color3.fromRGB(219, 120, 171), Color3.fromRGB(53, 184, 183), Color3.fromRGB(44, 51, 65)}
local random = Random.new()
local bags = {}
local function varied(palette, cf, category)
 -- Independent shuffled bags per sidewalk: every palette repeats on BOTH sides.
 local key = category .. (cf.Position.Z < 0 and "North" or "South")
 local bag = bags[key]
 if not bag or #bag == 0 then
  bag = table.clone(palette)
  for i = #bag, 2, -1 do local j = random:NextInteger(1, i) bag[i], bag[j] = bag[j], bag[i] end
  bags[key] = bag
 end
 return table.remove(bag)
end
local serial = 0
local function fallback(parent, name, cf, color, skin)
 serial += 1
 local model = Instance.new("Model") model.Name = name
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
function Characters.Create(parent, name, cf, color)
 local model
 local skin = varied(skins, cf, "Skin")
 if name == "Passant" or name == "Touriste" then color = varied(outfits, cf, "Outfit") end
 if template then
  serial += 1
  model = template:Clone() model.Name = name
  for _, item in ipairs(model:GetDescendants()) do
   if item:IsA("BaseScript") then item:Destroy() end
  end
  local colors = model:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors", model)
  colors.HeadColor3, colors.LeftArmColor3, colors.RightArmColor3 = skin, skin, skin
  colors.TorsoColor3 = color
  colors.LeftLegColor3, colors.RightLegColor3 = Color3.fromRGB(40, 50, 70), Color3.fromRGB(40, 50, 70)
  model.PrimaryPart = model:FindFirstChild("HumanoidRootPart")
  model:PivotTo(cf * CFrame.new(0, 3.1, 0))
  model.Parent = parent
 else
  model = fallback(parent, name, cf, color, skin)
 end
 local hum = model:FindFirstChildOfClass("Humanoid")
 local function clothing(n, size, limb, offset, tint)
   local p = Instance.new("Part")
   p.Name, p.Size, p.Color = n, size, tint
   p.CanCollide, p.CanTouch, p.CanQuery, p.Massless = false, false, false, true
   p.CFrame, p.Parent = limb.CFrame * offset, model
   local weld = Instance.new("WeldConstraint") weld.Part0, weld.Part1, weld.Parent = limb, p, p
   return p
  end
 if name == "Touriste" then
  model:SetAttribute("Tourist", true)
  local head, torso = model.Head, model.Torso
  local straw = Color3.fromRGB(234, 206, 143)
  clothing("VacationHatBrim", Vector3.new(2.5, 0.12, 1.9), head, CFrame.new(0, 0.6, 0), straw)
  clothing("VacationHatCrown", Vector3.new(1.6, 0.45, 1.3), head, CFrame.new(0, 0.85, 0), straw)
  clothing("VacationHatRibbon", Vector3.new(1.65, 0.14, 1.35), head, CFrame.new(0, 0.7, 0), color)
  for _, x in ipairs({-0.42, 0.42}) do clothing("Sunglasses", Vector3.new(0.65, 0.3, 0.12), head, CFrame.new(x, 0.12, -0.55), Color3.fromRGB(25, 36, 48)) end
  clothing("GlassesBridge", Vector3.new(0.25, 0.08, 0.12), head, CFrame.new(0, 0.12, -0.55), Color3.fromRGB(25, 36, 48))
  clothing("VacationShirt", Vector3.new(2.05, 1.95, 1.05), torso, CFrame.identity, color)
  for i = 1, 4 do
   clothing("ShirtPattern", Vector3.new(0.3, 0.22, 0.04), torso, CFrame.new(i % 2 == 0 and 0.55 or -0.55, 0.8 - i * 0.33, -0.55) * CFrame.Angles(0, 0, math.rad(35)), straw)
  end
  for _, nameOfLeg in ipairs({"Left Leg", "Right Leg"}) do
   local leg = model[nameOfLeg] leg.Color = head.Color
   clothing("VacationShorts", Vector3.new(1.04, 1, 1.04), leg, CFrame.new(0, 0.5, 0), Color3.fromRGB(237, 218, 174))
   clothing("Sandal", Vector3.new(1.06, 0.16, 1.18), leg, CFrame.new(0, -0.96, -0.06), Color3.fromRGB(104, 73, 43))
  end
  clothing("VacationBackpack", Vector3.new(1.3, 1.4, 0.55), torso, CFrame.new(0, 0, 0.8), Color3.fromRGB(207, 115, 68))
 elseif name == "Cashier" then
  local torso = model.Torso
  local white, navy = Color3.fromRGB(242, 239, 230), Color3.fromRGB(28, 36, 49)
  clothing("CashierShirt", Vector3.new(2.04, 2.02, 1.04), torso, CFrame.identity, white)
  for _, side in ipairs({"Left", "Right"}) do
   clothing("CashierSleeve", Vector3.new(1.03, 1.35, 1.03), model[side .. " Arm"], CFrame.new(0, 0.3, 0), white)
   clothing("CashierTrousers", Vector3.new(1.03, 2.02, 1.03), model[side .. " Leg"], CFrame.identity, navy)
  end
  clothing("CashierApron", Vector3.new(1.45, 1.65, 0.1), torso, CFrame.new(0, -0.15, -0.58), color)
  for _, x in ipairs({-0.5, 0.5}) do
   clothing("ApronStrap", Vector3.new(0.18, 0.65, 0.1), torso, CFrame.new(x, 0.7, -0.57), color)
  end
  local badge = clothing("CashierNameBadge", Vector3.new(0.65, 0.3, 0.08), torso, CFrame.new(0.35, 0.4, -0.68), white)
  local gui = Instance.new("SurfaceGui") gui.Face, gui.Parent = Enum.NormalId.Front, badge
  local label = Instance.new("TextLabel") label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
  label.Text, label.TextScaled, label.TextColor3, label.Font = "CAISSE", true, navy, Enum.Font.GothamBold
  label.Parent = gui
 end
 hum.DisplayDistanceType, hum.BreakJointsOnDeath = Enum.HumanoidDisplayDistanceType.None, false
 hum.WalkSpeed, hum.AutoRotate = 7, true
 for _, part in ipairs(model:GetDescendants()) do
  if part:IsA("BasePart") then
   part.Anchored = false
   part.CollisionGroup = "CEONPC"
   part.CanCollide = part.Name == "Torso" or part.Name == "Head"
  end
 end
 if model:IsDescendantOf(workspace) then model.PrimaryPart:SetNetworkOwner(nil) end
 local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
 local tracks = {}
 if model:IsDescendantOf(workspace) then
  for key, id in pairs({Walk = "180426354", Idle = "180435571"}) do
   local animation = Instance.new("Animation") animation.AnimationId = "rbxassetid://" .. id
   local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
   animation:Destroy()
   if ok then track.Looped = true track.Priority = key == "Walk" and Enum.AnimationPriority.Movement or Enum.AnimationPriority.Idle tracks[key] = track
   else warn("[NPC] Animation unavailable: " .. tostring(track)) end
  end
 end
 local function animate(speed)
  local walking = speed > 0.2 and not model:GetAttribute("Carried")
  local active, inactive = tracks[walking and "Walk" or "Idle"], tracks[walking and "Idle" or "Walk"]
  if inactive and inactive.IsPlaying then inactive:Stop(0.15) end
  if active then
   if not active.IsPlaying then active:Play(0.15) end
   if walking then active:AdjustSpeed(math.clamp(speed / 14.5, 0.2, 1.5)) end
  end
 end
 hum.Running:Connect(animate)
 model:GetAttributeChangedSignal("Carried"):Connect(function()
  local carried = model:GetAttribute("Carried") == true
  -- Carry owns all anchoring/collision changes; animation must never anchor its carrier.
  hum:Move(Vector3.zero)
  animate(0)
 end)
 animate(0)
 model:SetAttribute("StandardRobloxRig", template ~= nil)
 CollectionService:AddTag(model, "CEONPC")
 return model
end
return Characters
