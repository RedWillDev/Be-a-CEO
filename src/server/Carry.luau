-- One attachment lifecycle for every carryable entity. No per-frame PivotTo.
local TweenService = game:GetService("TweenService")
local Carry = {}
Carry.__index = Carry
local entities, carriers = {}, {}

function Carry.Parcel(model, scale)
 local width = model.PrimaryPart.Size.X / 2
 return {Offset = CFrame.new(0, -0.15 * scale, -1.7 * scale),
  Hands = {Left = Vector3.new(-width - 0.2, -0.15, 0.15), Right = Vector3.new(width + 0.2, -0.15, 0.15)}}
end
function Carry.Person(_model, scale)
 -- Cradled sideways: one hand supports the back, the other the legs.
 return {Offset = CFrame.new(0, 0.15 * scale, -1.65 * scale) * CFrame.Angles(0, math.pi / 2, 0),
  Hands = {Left = Vector3.new(0, -0.6, -1), Right = Vector3.new(0, 0.25, 0.65)}}
end
function Carry.new(character, model, kind)
 local hum = character and character:FindFirstChildOfClass("Humanoid")
 local root = character and character:FindFirstChild("HumanoidRootPart")
 assert(hum and root and model.PrimaryPart, "Carry requires a character and an entity root")
 assert(kind == "Parcel" or kind == "Tourist" or kind == "VIP", "Unknown carry kind")
 local scale = hum.RigType == Enum.HumanoidRigType.R6 and 1 or math.clamp((hum.HipHeight + root.Size.Y / 2) / 3, 0.8, 1.25)
 return setmetatable({Character = character, Model = model, Humanoid = hum, Root = root, Kind = kind,
  Settings = kind == "Parcel" and Carry.Parcel(model, scale) or Carry.Person(model, scale), Items = {}, Parts = {}}, Carry)
end
function Carry:Attach()
 assert(not self.Attached and not entities[self.Model] and not carriers[self.Character], "Already carrying")
 self.Attached = true entities[self.Model] = self carriers[self.Character] = self
 self.Speed = self.Humanoid.WalkSpeed
 for _, part in ipairs(self.Model:GetDescendants()) do
  if part:IsA("BasePart") then
   self.Parts[part] = {Anchored = part.Anchored, CanCollide = part.CanCollide, CanTouch = part.CanTouch, Massless = part.Massless}
  end
 end
 self.Passenger = self.Model:FindFirstChildOfClass("Humanoid")
 if self.Passenger then
  self.AutoRotate, self.PlatformStand = self.Passenger.AutoRotate, self.Passenger.PlatformStand
  self.Passenger:Move(Vector3.zero) self.Passenger.AutoRotate = false self.Passenger.PlatformStand = true
 end
 self.Model:SetAttribute("Carried", true)
 for part in pairs(self.Parts) do part.Anchored = false part.CanCollide = false part.CanTouch = false part.Massless = true end
 local grip = Instance.new("Motor6D")
 grip.Name, grip.Part0, grip.Part1 = "CarryGrip", self.Root, self.Model.PrimaryPart
 grip.C0 = self.Root.CFrame:ToObjectSpace(self.Model.PrimaryPart.CFrame)
 grip.Parent = self.Root self.Grip = grip
 self.Tween = TweenService:Create(grip, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C0 = self.Settings.Offset})
 self.Tween:Play()
 for side, point in pairs(self.Settings.Hands) do
  local target = Instance.new("Attachment") target.Name = side .. "CarryHand" target.Position = point target.Parent = self.Model.PrimaryPart
  table.insert(self.Items, target)
  local hand, upper = self.Character:FindFirstChild(side .. "Hand"), self.Character:FindFirstChild(side .. "UpperArm")
  if hand and upper then
   local pole = Instance.new("Attachment") pole.Name = side .. "CarryElbow"
   pole.Position = Vector3.new(side == "Left" and -1.8 or 1.8, -0.8, -0.6) pole.Parent = self.Root
   table.insert(self.Items, pole)
   local ik = Instance.new("IKControl") ik.Name = side .. "CarryIK" ik.Type = Enum.IKControlType.Position
   ik.ChainRoot, ik.EndEffector, ik.Target, ik.Pole = upper, hand, target, pole
   ik.SmoothTime, ik.Weight, ik.Priority = 0.06, 1, 10 ik.Parent = self.Humanoid
   table.insert(self.Items, ik)
  end
 end
 self.Character:SetAttribute("CarryKind", self.Kind)
 self.Humanoid.WalkSpeed = 11
 self.Death = self.Humanoid.Died:Connect(function() self:Detach() end)
 self.Removal = self.Model.Destroying:Connect(function() self:Detach() end)
 self.CharacterRemoval = self.Character.Destroying:Connect(function() self:Detach() end)
 return self
end
function Carry:Detach()
 if not self.Attached then return end
 self.Attached = false entities[self.Model] = nil carriers[self.Character] = nil
 if self.Death then self.Death:Disconnect() end
 if self.Removal then self.Removal:Disconnect() end
 if self.CharacterRemoval then self.CharacterRemoval:Disconnect() end
 if self.Tween then self.Tween:Cancel() end
 if self.Grip then self.Grip:Destroy() end
 for _, item in ipairs(self.Items) do item:Destroy() end
 self.Character:SetAttribute("CarryKind", nil)
 self.Humanoid.WalkSpeed = self.Speed
 -- Always detach before restoring anchors/collisions: never anchor the player.
 self.Model:SetAttribute("Carried", false)
 for part, properties in pairs(self.Parts) do
  if part.Parent then for key, value in pairs(properties) do part[key] = value end end
 end
 if self.Passenger and self.Passenger.Parent then
  self.Passenger.AutoRotate, self.Passenger.PlatformStand = self.AutoRotate, self.PlatformStand
 end
end
function Carry.Release(model)
 local handle = entities[model]
 if handle then handle:Detach() end
end
return Carry
