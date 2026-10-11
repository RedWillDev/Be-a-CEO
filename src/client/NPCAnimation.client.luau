local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local rigs = {}
local function add(model)
 local root = model:FindFirstChild("HumanoidRootPart") local torso = model:FindFirstChild("Torso")
 if not root or not torso then return end
 local joints = {}
 for _, j in ipairs(model:GetDescendants()) do if j:IsA("Motor6D") then joints[j.Name] = j end end
 rigs[model] = {Root = root, Joints = joints, Last = root.Position, Phase = model:GetAttribute("VisualSeed") or 0, Speed = 0}
end
CollectionService:GetInstanceAddedSignal("CEONPC"):Connect(add)
CollectionService:GetInstanceRemovedSignal("CEONPC"):Connect(function(m) rigs[m] = nil end)
for _, model in ipairs(CollectionService:GetTagged("CEONPC")) do add(model) end
RunService.PreSimulation:Connect(function(dt)
 for model, rig in pairs(rigs) do
  if not model.Parent then rigs[model] = nil continue end
  local speed = (rig.Root.Position - rig.Last).Magnitude / math.max(dt, 0.001)
  rig.Last = rig.Root.Position
  rig.Speed += (math.min(speed, 12) - rig.Speed) * math.min(dt * 8, 1)
  local moving = rig.Speed > 0.7 and not model:GetAttribute("Carried")
  rig.Phase += dt * (moving and 9 or 2)
  local swing = moving and math.sin(rig.Phase) * 0.6 or math.sin(rig.Phase) * 0.035
  for _, info in ipairs({{"Left Hip", swing}, {"Right Hip", -swing}, {"Left Shoulder", -swing * 0.8}, {"Right Shoulder", swing * 0.8}}) do
   local j = rig.Joints[info[1]] if j then j.Transform = CFrame.Angles(info[2], 0, 0) end
  end
  local neck = rig.Joints.Neck if neck then neck.Transform = CFrame.Angles(0, math.sin(rig.Phase * 0.3) * 0.09, 0) end
 end
end)
