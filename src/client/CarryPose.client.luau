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
  -- Parcel R15 arms are solved by IKControl against the box, not fixed angles.
  if c and c:GetAttribute("CarryingTourist") then wanted[c] = false end
  if c and c:GetAttribute("CarryingParcel") and c:FindFirstChild("Torso") then wanted[c] = false end
 end
 for _, m in ipairs(CollectionService:GetTagged("CEONPC")) do
  if m:GetAttribute("Tourist") and m:GetAttribute("Carried") then wanted[m] = true end
 end
 for model, passenger in pairs(wanted) do
  if not active[model] then active[model] = {Joints = pose(model, passenger), Weight = 0} end
  local state = active[model]
  state.Weight = math.min(1, state.Weight + dt * 6)
  for j, target in pairs(state.Joints) do
   if j.Parent then
    local root = model:FindFirstChild("HumanoidRootPart")
    local grip = root and root:FindFirstChild("ParcelGrip")
    if model:GetAttribute("CarryingParcel") and grip and grip.Part1 and (j.Name == "Left Shoulder" or j.Name == "Right Shoulder") then
     local box = grip.Part1
     local side = j.Name == "Left Shoulder" and -1 or 1
     local handPoint = box.CFrame:PointToWorldSpace(Vector3.new(side * (box.Size.X / 2 + 0.2), -0.15, 0))
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
