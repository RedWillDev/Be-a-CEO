-- Local-only map hints: never expose another player's delivery or change gameplay.
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local state = game.ReplicatedStorage:WaitForChild("BeACEO"):WaitForChild("State")
local snapshot
local function marker(name, color)
 local gui = Instance.new("BillboardGui")
 gui.Name, gui.Size, gui.StudsOffset, gui.AlwaysOnTop = name, UDim2.fromOffset(180, 42), Vector3.new(0, 3, 0), true
 gui.MaxDistance, gui.Enabled, gui.Parent = 350, false, player:WaitForChild("PlayerGui")
 gui.ResetOnSpawn = false
 local label = Instance.new("TextLabel")
 label.Size, label.BackgroundColor3, label.BackgroundTransparency = UDim2.fromScale(1, 1), Color3.fromRGB(24, 34, 58), 0.1
 label.Font, label.TextSize, label.TextColor3, label.TextWrapped = Enum.Font.GothamBold, 14, color, true
 label.Parent = gui
 local corner = Instance.new("UICorner") corner.CornerRadius, corner.Parent = UDim.new(0, 10), label
 return gui, label
end
local home, homeText = marker("MyShopMarker", Color3.fromRGB(70, 224, 151))
local hint, hintText = marker("NextActionMarker", Color3.fromRGB(255, 208, 92))
local glow = Instance.new("Highlight")
glow.Name, glow.FillTransparency, glow.OutlineColor = "NextActionHighlight", 0.85, Color3.fromRGB(255, 208, 92)
glow.FillColor, glow.Enabled, glow.Parent = glow.OutlineColor, false, workspace
state.OnClientEvent:Connect(function(value) snapshot = value end)
local function display(gui, label, target, text, root)
 gui.Enabled = target ~= nil and root ~= nil
 gui.Adornee = target
 if target and root then
  label.Text = text .. "\n" .. math.floor((root.Position - target.Position).Magnitude) .. " studs"
 end
end
task.spawn(function()
 while script.Parent do
  task.wait(0.25)
  local city = workspace:FindFirstChild("CEOCity")
  local shop = snapshot and city and city:FindFirstChild("Company" .. snapshot.Plot)
  local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  local target, text
  if shop and snapshot then
   local d = snapshot.Data
   local staff = d.Staff or {}
   if snapshot.Carrying then
    target, text = shop:FindFirstChild("CashRegister"), "RAPPORTE ICI"
   elseif snapshot.Waiting and (staff.Cashier or 0) == 0 then
    target, text = shop:FindFirstChild("CashRegister"), "ENCAISSER"
   elseif d.Parcel and (staff.Receiver or 0) == 0 then
    for _, model in ipairs(city:GetChildren()) do
     if model.Name == "DeliveryParcel" and model:GetAttribute("OwnerId") == player.UserId then
      target, text = model.PrimaryPart, "PRENDS TON COLIS"
      break
     end
    end
   elseif d.Stock == 0 and not d.Order and not d.Parcel and not (staff.Buyer and staff.Buyer > 0 and d.AutoOrder) then
    target, text = shop:FindFirstChild("MarketBridge"), "COMMANDER"
   end
  end
  local entrance = shop and shop:FindFirstChild("GuideEntrance")
  display(home, homeText, entrance, "TA BOUTIQUE", root)
  if target and entrance and root and (root.Position - entrance.Position).Magnitude < 20 then home.Enabled = false end
  display(hint, hintText, target, text, root)
  glow.Adornee, glow.Enabled = target, target ~= nil
 end
end)
