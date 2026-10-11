if not game:GetService("RunService"):IsStudio() then return end
local Characters = require(script.Parent.Characters)
local VehicleArt = require(script.Parent.VehicleArt)
local W = require(script.Parent.World)
local folder = Instance.new("Folder") folder.Name = "CEOVisualChecks" folder.Parent = game.ServerStorage
local count = 0
local function check(ok, message) count += 1 assert(ok, "[Visual checks] " .. message) end
local ok, failure = pcall(function()
 local npc = Characters.Create(folder, "Touriste", CFrame.new(), Color3.new(0, 1, 0))
 check(npc:FindFirstChildOfClass("Humanoid") ~= nil, "humanoid exists")
 check(npc.PrimaryPart.Name == "HumanoidRootPart" and npc.PrimaryPart.Anchored, "stable root")
 local motors = 0 for _, item in ipairs(npc:GetDescendants()) do if item:IsA("Motor6D") then motors += 1 end end
 check(motors == 6, "six articulation joints")
 check(npc:FindFirstChild("Backpack") and npc:FindFirstChild("HatBrim"), "tourist accessories")
 for _, kind in ipairs({"Car", "TourBus", "DeliveryVan"}) do
  local model = VehicleArt.Build(folder, CFrame.new(), kind, 5, Color3.new(1, 0, 0), W.Part)
  check(model.PrimaryPart.Name == "Chassis", kind .. " pivot")
  local tires, parts = 0, 0
  for _, part in ipairs(model:GetChildren()) do
   if part.Name == "Tire" then tires += 1 end
   if part:IsA("BasePart") then parts += 1 check(part.Anchored, "anchored vehicle assembly") end
  end
  check(tires == 4 and parts > 60, kind .. " detail and wheels")
 end
end)
folder:Destroy()
assert(ok, failure)
print("[Visual checks] PASS: " .. count .. " assertions; articulated NPCs and three vehicle classes.")
