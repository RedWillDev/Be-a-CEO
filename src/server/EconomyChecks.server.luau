-- In-memory checks only. Never touches a player's profile or DataStore.
if not game:GetService("RunService"):IsStudio() then return end
local E = require(script.Parent.Economy)
local C = require(game.ReplicatedStorage.BeACEO.Config)
local assertions = 0
local function check(condition, message)
 assertions += 1
 assert(condition, "[Be-a-CEO checks] " .. message)
end
local a, b = E.New(), E.New()
for level = 1, #C.Levels do
 local d = E.New()
 d.Level, d.Cash = level, 10000
 check(E.Capacity(d) == 25 * (level + 1), "capacity grows with company")
 d.Stock = E.Capacity(d) - 9
 check(not E.Action(d, "Order") and d.Cash == 10000, "reject overflow without charging")
 d.Stock = E.Capacity(d) - 10
 check(E.Action(d, "Order"), "accept exact capacity batch")
end
check(a.Cash == 500 and a.Stock == 0, "starting balance")
check(E.Action(a, "Negotiate", "Volume"), "negotiation accepted")
check(E.OrderCost(a) == 162, "discount calculation")
check(E.Action(a, "Order"), "first order")
check(a.Cash == 338 and a.Order.Remaining == 7, "order charged once")
check(not E.Action(a, "Order"), "reject duplicate pending order")
check(a.Cash == 338, "duplicate does not charge")
check(b.Cash == 500 and not b.Order and not b.Negotiated, "profiles isolated")
check(not E.Action(a, "Vehicle", 5), "vehicle level gate")
check(not E.Action(a, "Luxury", 1), "working capital protected")
a.Stock, a.Order = 10, nil
check(E.Sale(a) == 40 and a.Stock == 9 and a.Cash == 378, "stock exchanged for revenue")
check(not E.Action(a, "Product", 3), "cannot convert existing stock")
a.Stock = 0
check(E.Sale(a, 3) == 0, "no VIP payout without stock")
a.Sales, a.Cash = 10, 600
check(not E.Action(a, "Upgrade"), "upgrade cannot bankrupt company")
a.Cash = 10000
check(E.Action(a, "Upgrade") and a.Level == 2 and a.Cash == 9400, "upgrade price and level")
check(E.Action(a, "Vehicle", 2) and a.Cash == 8450, "vehicle paid from company")
check(E.Action(a, "Vehicle", 2) and a.Cash == 8450, "owned vehicle respawn free")
check(E.Action(a, "Luxury", 1) and a.Cash == 8200, "personal luxury payment")
check(not E.Action(a, "Luxury", 1) and a.Cash == 8200, "no duplicate luxury payment")
check(not E.Action(a, "Price", 0), "invalid price rejected")
check(not E.Action(a, "Supplier", 99), "invalid supplier rejected")
check(not E.Action(a, "Vehicle", "invalid"), "invalid vehicle rejected")
for product = 1, #C.Products do
 for supplier = 1, #C.Suppliers do
  local d = E.New()
  d.Product, d.Supplier, d.Cash, d.Stock = product, supplier, 10000, 10
  local cost = E.OrderCost(d)
  local revenue = 0
  for _ = 1, 10 do revenue += E.Sale(d) end
  check(revenue > cost, "base order profitability")
  check(d.Stock == 0 and E.Sale(d) == 0, "stock cannot be oversold")
 end
end
print("[Be-a-CEO checks] PASS: " .. assertions .. " economy assertions; isolated profiles; no saved data touched.")
