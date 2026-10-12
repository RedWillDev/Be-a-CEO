-- Custom carry pose: Roblox has no default two-character carry animation.
-- Applied after Animator evaluation; normal walking remains on the carrier's legs.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local active = {}
local function pose(model, passenger)
 local joints = {}
 for _, j in ipairs(model:GetDescendants()) do
  if j:IsA("Motor6D") then
   local name = j.Name:gsub(" ", "")
   local angle
   if passenger then
    if name == "LeftHip" or name == "RightHip" then angle = 85 end
    if name == "LeftShoulder" or name == "RightShoulder" then angle = 15 end
   else
    if name == "LeftShoulder" or name == "RightShoulder" then angle = 75 end
    if name == "LeftElbow" or name == "RightElbow" then angle = 25 end
   end
   if angle then
    local axes = j.C0.Rotation
    joints[j] = axes:Inverse() * CFrame.Angles(math.rad(angle), 0, 0) * axes
   end
  end
 end
 return joints
end
RunService.PreSimulation:Connect(function(dt)
 local wanted = {}
 for _, player in ipairs(Players:GetPlayers()) do
  local c = player.Character
  -- All R15 carry types use the module's IK hand targets. R6 has rigid arms.
  if c and c:GetAttribute("CarryKind") and c:FindFirstChild("Torso") then wanted[c] = false end
 end
 for _, m in ipairs(CollectionService:GetTagged("CEONPC")) do
  if m:GetAttribute("Carried") then wanted[m] = true end
  if m:GetAttribute("CarryKind") and m:FindFirstChild("Torso") then wanted[m] = false end
 end
 for model, passenger in pairs(wanted) do
  if not active[model] then active[model] = {Joints = pose(model, passenger), Weight = 0} end
  local state = active[model]
  state.Weight = math.min(1, state.Weight + dt * 6)
  for j, target in pairs(state.Joints) do
   if j.Parent then
    local root = model:FindFirstChild("HumanoidRootPart")
    local grip = root and root:FindFirstChild("CarryGrip")
    if model:GetAttribute("CarryKind") and grip and grip.Part1 and (j.Name == "Left Shoulder" or j.Name == "Right Shoulder") then
     local side = j.Name == "Left Shoulder" and "Left" or "Right"
     local attachment = grip.Part1:FindFirstChild(side .. "CarryHand")
     if not attachment then continue end
     local handPoint = attachment.WorldPosition
     local shoulder = j.Part0.CFrame * j.C0
     local delta = handPoint - shoulder.Position
     if delta.Magnitude > 0.01 then
      local center = handPoint - delta.Unit * (j.Part1.Size.Y / 2)
      local arm = CFrame.lookAt(center, center + delta.Unit) * CFrame.Angles(math.pi / 2, 0, 0)
      target = shoulder:ToObjectSpace(arm * j.C1)
     end
    end
    j.Transform = j.Transform:Lerp(target, state.Weight)
   end
  end
 end
 for model, state in pairs(active) do
  if wanted[model] == nil then
   state.Weight = math.max(0, state.Weight - dt * 7)
   for j, target in pairs(state.Joints) do if j.Parent then j.Transform = j.Transform:Lerp(target, state.Weight) end end
   if state.Weight == 0 or not model.Parent then active[model] = nil end
  end
 end
end)
