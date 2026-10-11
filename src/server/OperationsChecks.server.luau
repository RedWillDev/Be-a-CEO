if not game:GetService("RunService"):IsStudio() then return end
local E = require(script.Parent.Economy)
local S = require(script.Parent.Staff)
local L = require(script.Parent.Logistics)
local count = 0
local function check(ok, message) count += 1 assert(ok, "[Operations checks] " .. message) end
local a, b = E.New(), E.New()
S.Init(a) S.Init(b)
check(a.Staff.Cashier == 0 and a.Staff ~= b.Staff, "independent staff")
check(not S.Hire(a, 4, 180), "manager level gate")
check(S.Hire(a, 1, 180) and a.Cash == 380 and a.Staff.Cashier == 1, "hire cashier")
check(not S.Hire(a, 1, 180) and a.Cash == 380, "training protects reserve")
check(not S.Hire(a, 99, 180), "invalid role")
a.Level, a.Cash = 4, 10000
check(S.Hire(a, 4, 180), "manager unlock")
check(not S.Manage(a, 180), "manager opt in")
a.ManagerEnabled = true
check(S.Manage(a, 180) and a.Staff.Receiver == 1, "manager hires next role")
check(S.Manage(a, 180) and a.Staff.Buyer == 1, "manager hires buyer")
check(not S.Manage(a, 180), "manager respects own rank")
a.Parcel = {Units = 10, Product = 1, Quality = 1.5, Paid = 180}
check(not E.Action(a, "Order"), "unreceived parcel blocks duplicate shipment")
check(not E.Action(a, "Product", 2), "parcel prevents product conversion")
local sessions = {A = {Data = a}, B = {Data = b}}
local logistics = L.Start(sessions, {}, E, {}, function() end, function() return true end, function() return false end)
check(logistics:Receive("A", "A") and a.Stock == 10 and a.Quality == 1.5, "parcel stocks once")
check(not logistics:Receive("A", "A") and a.Stock == 10, "no duplicate receipt")
a.Parcel = {Units = 10, Product = 1, Quality = 1, Paid = 180}
check(not logistics:Receive("A", "B"), "beginner protected")
b.Level, a.Rivalry, b.Rivalry = 2, true, true
b.Product = 2
check(not logistics:Receive("A", "B"), "cannot convert stolen merchandise")
b.Product = 1 local before = a.Cash
check(logistics:Receive("A", "B") and b.Stock == 10 and a.Cash == before + 90 and not a.Parcel, "opt in Studio theft and insurance")
check(not logistics:Receive("A", "B") and b.Stock == 10, "theft cannot repeat")
print("[Operations checks] PASS: " .. count .. " assertions; staff, parcels, protection and Studio transfers.")
