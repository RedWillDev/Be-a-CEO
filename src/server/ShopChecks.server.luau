-- Isolated display checks. No live plot, player, economy or saved data is changed.
if not game:GetService("RunService"):IsStudio() then return end
local W = require(script.Parent.World)
local E = require(script.Parent.Economy)
local folder = Instance.new("Model")
folder.Name, folder.Parent = "CEOShopChecks", game.ServerStorage
local inventory = Instance.new("Folder")
inventory.Name, inventory.Parent = "VisibleStock", folder
for _, name in ipairs({"StockSign", "BuyerStation", "ManagerStation"}) do
 local sign = W.Sign(folder, "", CFrame.new())
 sign.Name = name
end
local count = 0
local function check(ok, message)
 count += 1
 assert(ok, "[Shop checks] " .. message)
end
local previous = W.Plots[0]
W.Plots[0] = {CF = CFrame.new(), Model = folder}
local ok, failure = pcall(function()
 local d = E.New()
 W.UpdateStock(0, d)
 check(#inventory:GetChildren() == 0, "empty stock means empty shelves")
 d.Stock = 10
 W.UpdateStock(0, d)
 check(#inventory:GetChildren() == 10, "ten received units displayed")
 local first = inventory:FindFirstChild("1")
 W.UpdateStock(0, d)
 check(inventory:FindFirstChild("1") == first, "unchanged display is preserved")
 check(W.BrowsePosition(0, 2).Z == -8, "client selects stocked rack")
 E.Sale(d)
 W.UpdateStock(0, d)
 check(#inventory:GetChildren() == 9 and inventory:FindFirstChild("1") == first, "sale removes exactly one display")
 d.Stock, d.Level = 75, 2
 W.UpdateStock(0, d)
 check(#inventory:GetChildren() == 75, "upgraded display fits larger stock")
 check(W.BrowsePosition(0, 2).Z == -2, "second stocked rack can be browsed")
 for product = 1, 3 do
  d.Product = product
  W.UpdateStock(0, d)
  check(#inventory:GetChildren() == 75 and inventory:GetAttribute("Product") == product, "display uses selected product")
 end
 d.Stock = 0
 W.UpdateStock(0, d)
 check(#inventory:GetChildren() == 0, "liquidation clears display")
 W.UpdateStock(0, nil)
 check(folder.BuyerStation.SurfaceGui.TextLabel.Text:find("pourvoir") ~= nil, "unowned office has no active employee")
end)
W.Plots[0] = previous
folder:Destroy()
assert(ok, failure)
print("[Shop checks] PASS: " .. count .. " isolated stock display assertions.")
