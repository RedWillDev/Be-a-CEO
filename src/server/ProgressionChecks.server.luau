if not game:GetService("RunService"):IsStudio() then return end
local P = require(script.Parent.Progression)
local E = require(script.Parent.Economy)
local count = 0
local function check(ok, message)
 count += 1 assert(ok, "[Progression checks] " .. message)
end
local now = 2000000000
local d = E.New()
P.Init(d, now)
check(d.Daily.Sales == 0 and d.Reputation == 0, "migration initializes fields")
check(not P.Action(d, "Mission", 1, now, 180), "unearned mission rejected")
d.Sales = 5
check(P.Action(d, "Mission", 1, now, 180) and d.Cash == 600, "mission paid")
check(not P.Action(d, "Mission", 1, now, 180) and d.Cash == 600, "mission once only")
check(P.Action(d, "DailyGift", nil, now, 180) and d.Cash == 675, "daily gift paid")
check(not P.Action(d, "DailyGift", nil, now, 180), "daily gift once only")
check(P.Action(d, "DailyGift", nil, now + 3 * 86400, 180) and d.DailyCount == 2, "missed day preserves calendar")
check(not P.Action(d, "DailyGift", nil, now, 180), "backward clock cannot reclaim gift")
check(not E.Action(d, "Negotiate", "Loyalty"), "loyalty requires history")
for _ = 1, 3 do P.OnOrder(d, now) end
check(E.Action(d, "Negotiate", "Loyalty") and E.OrderCost(d) == 153, "loyalty discount")
E.Action(d, "Order")
check(not d.Negotiated and not d.Discount, "discount consumed")
d.Order = nil
check(E.Action(d, "Negotiate", "Sample") and E.OrderCost(d) == 180, "sample not discounted")
check(E.Action(d, "Order") and d.Order.Quality == 1.2, "sample improves quality")
check(not P.Action(d, "AutoOrder", nil, now, 180), "automation requires boutique")
d.Level = 2
check(P.Action(d, "AutoOrder", nil, now, 180) and d.AutoOrder, "automation enabled")
check(P.Action(d, "AutoOrder", nil, now, 180) and not d.AutoOrder, "automation disabled")
d.Cash = 200
check(not P.Action(d, "Marketing", nil, now, 180), "marketing reserve protected")
d.Cash = 500
check(P.Action(d, "Marketing", nil, now, 180) and d.Cash == 400, "marketing charged")
check(not P.Action(d, "Marketing", nil, now, 180) and d.Cash == 400, "cannot buy overlapping campaign")
d.Stock, d.LastSeen = 10, now - 1200
local earned, units = P.Offline(d, now, E.Sale)
check(earned == 200 and units == 10 and d.Stock == 0, "offline consumes real stock at half price")
check(P.Offline(d, now, E.Sale) == 0, "offline cannot duplicate")
d.Stock, d.LastSeen = 500, now - 86400
earned, units = P.Offline(d, now, E.Sale)
check(units == 120, "offline capped at four hours")
d.LastSeen = now + 100
check(P.Offline(d, now, E.Sale) == 0, "negative elapsed produces no earnings")
P.Init(d, now)
for _ = 1, 15 do P.OnSale(d, "Local", now) end
check(P.Action(d, "DailyMission", 1, now, 180), "daily sales reward")
check(not P.Action(d, "DailyMission", 1, now, 180), "daily reward once only")
P.Init(d, now + 86400)
check(d.Daily.Sales == 0 and not d.Daily.Claims["1"], "day resets counters")
local sales = d.Sales d.Stock = 10
check(P.Action(d, "Liquidate", nil, now + 86400, 180) and d.Stock == 0 and d.Sales == sales, "liquidation is not mission farming")
check(not P.Action(d, "Mission", 99, now, 180), "invalid mission rejected")
check(P.Action(d, "Unknown", nil, now, 180) == nil, "unknown action delegates")
print("[Progression checks] PASS: " .. count .. " assertions; rewards, negotiation, offline and migration.")
