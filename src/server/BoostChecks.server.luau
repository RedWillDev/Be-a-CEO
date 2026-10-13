if not game:GetService("RunService"):IsStudio() then return end
local Movement = require(script.Parent.Movement)
local Info = require(game.ReplicatedStorage.BeACEO.EventInfo)
local E = require(script.Parent.Economy)
local P = require(script.Parent.Progression)
local count = 0
local function check(ok, message) count += 1 assert(ok, "[Boost checks] " .. message) end
local d = {Sales = 0}
Movement.Init(d, 1000)
check(d.StarterBoostEnds == 1180, "three minute welcome")
Movement.Init(d, 1100)
check(d.StarterBoostEnds == 1180, "join or reset does not renew")
Movement.Init(d, 1300)
check(d.StarterBoostEnds == 1180, "expired boost stays expired")
local veteran = {Sales = 10}
Movement.Init(veteran, 1000)
check(veteran.StarterBoostEnds == 0, "existing progressed profile excluded")
check(Movement.Speed(false, 1180, 1000) == 24, "boosted walking")
check(Movement.Speed(true, 1180, 1000) == 16.5, "boosted carrying still slower")
check(Movement.Speed(true, 1180, 1180) == 11, "expires during carry")
check(Movement.Speed(false, 1180, 1180) == 16, "drop after expiration restores normal")
check(Info.Timer(-5) == "00:00" and Info.Timer(180) == "03:00", "timer formatting")
local sales = E.New()
sales.Stock, sales.StarterBoostEnds = 10, 1180
check(E.Sale(sales, 1, 1000) == 80 and sales.Stock == 9, "live sales doubled, one unit sold")
check(E.Sale(sales, 2, 1000) == 160, "tourist bonus and starter multiply")
check(E.Sale(sales, 3, 1000) == 240, "VIP bonus and starter multiply")
check(E.Sale(sales, Info.CollectiveBonus, 1000) == 120, "collective contribution doubled")
check(E.Sale(sales, 1, 1180) == 40, "no doubling at expiry")
check(E.Sale(sales, 0.5) == 20, "offline calls never doubled")
local before = sales.Cash
P.Action(sales, "DailyGift", nil, 1000, E.OrderCost(sales))
check(sales.Cash - before == 75, "daily gift not doubled")
sales.Stock = 0
check(E.Sale(sales, 3, 1000) == 0, "boost cannot sell missing stock")
for _, entry in ipairs({{"Préparation", "aucun"}, {"Bus de touristes", "+20 %"}, {"Tendance surprise", "+30 %"}, {"Commande collective", "+50 %"}}) do
 check(Info.Describe({Kind = entry[1], Product = 1, Units = 0, Target = 30}):find(entry[2], 1, true) ~= nil, "correct event bonus " .. entry[1])
end
print("[Boost checks] PASS: " .. count .. " isolated assertions.")
