if not game:GetService("RunService"):IsStudio() then return end
local Guide = require(game.ReplicatedStorage.BeACEO.NextStep)
local E = require(script.Parent.Economy)
local Staff = require(script.Parent.Staff)
local d = E.New()
Staff.Init(d)
local snapshot = {Data = d}
local count = 0
local function contains(text)
 count += 1
 assert(Guide.Text(snapshot):find(text, 1, true), "[Guide checks] " .. text)
end
contains("commande 10 produits")
d.Order = {Remaining = 1}
contains("livraison arrive")
d.Order, d.Parcel = nil, {Units = 10}
contains("Prends le colis")
d.Staff.Receiver = 1
contains("réceptionnaire")
d.Parcel, d.Stock = nil, 10
contains("choisissent un produit")
snapshot.Waiting = true
contains("appuie sur Encaisser")
d.Staff.Cashier = 1
contains("Ton caissier")
snapshot.Carrying = true
contains("Ramène")
snapshot.Waiting, snapshot.Carrying = false, false
d.Stock, d.Staff.Buyer, d.AutoOrder = 0, 1, true
contains("responsable va commander")
d.Cash = 0
contains("Pas assez")
d.Cash, d.AutoOrder = 500, false
contains("commande 10 produits")
print("[Guide checks] PASS: " .. count .. " isolated next-step assertions.")
