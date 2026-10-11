local C = require(game.ReplicatedStorage.BeACEO.Config)
local E = {}
function E.New()
 return {Cash = 500, Level = 1, Sales = 0, Revenue = 0, Stock = 0, Quality = 1, Product = 1, Supplier = 1, PriceMode = 2, Color = 1, Vehicles = {}, Luxuries = {}, Negotiated = false}
end
function E.Price(d)
 return math.floor(C.Products[d.Product].Price * ({0.85, 1, 1.2})[d.PriceMode])
end
function E.OrderCost(d)
 return math.ceil(C.Products[d.Product].Cost * 10 * C.Suppliers[d.Supplier].Factor * (d.Negotiated and (1 - (d.Discount or 0.1)) or 1))
end
function E.Action(d, action, value, now)
 if action == "Product" then
  if d.Stock > 0 or d.Order or d.Parcel then return false, "Vends et réceptionne le stock actuel avant de changer de produit." end
  if not C.Products[value] then return false, "Produit invalide." end
  d.Product = value
 elseif action == "Supplier" then
  if not C.Suppliers[value] then return false, "Fournisseur invalide." end
  d.Supplier, d.Negotiated, d.Discount, d.Sample = value, false, nil, false
 elseif action == "Negotiate" then
  if d.Negotiated then return false, "Remise déjà obtenue pour le prochain lot." end
  if value ~= "Volume" and value ~= "Loyalty" and value ~= "Sample" then return false, "Offre invalide." end
  local history = d.SupplierOrders and (d.SupplierOrders[tostring(d.Supplier)] or 0) or 0
  if value == "Loyalty" and history < 3 then return false, "Ce fournisseur demande 3 commandes avant un accord de fidélité." end
  d.Discount = value == "Loyalty" and 0.15 or value == "Sample" and 0 or 0.1
  d.Sample = value == "Sample"
  d.Negotiated = true
  return true, value == "Sample" and "Contrôle qualité offert : +0,2 qualité sur le prochain lot, sans remise." or ("Accord MarketBridge : −" .. math.floor(d.Discount * 100) .. "% sur le prochain lot !")
 elseif action == "Order" then
  if d.Order or d.Parcel then return false, "Une livraison est déjà en route ou attend devant la porte." end
  if d.Stock > 40 then return false, "Stock presque plein : vends avant de recommander." end
  local cost = E.OrderCost(d)
  if d.Cash < cost then return false, "Trésorerie insuffisante pour ce lot." end
  d.Cash -= cost
  d.Order = {Remaining = C.Suppliers[d.Supplier].Delay, Quality = C.Suppliers[d.Supplier].Quality + (d.Sample and 0.2 or 0), Product = d.Product, Paid = cost}
  d.Negotiated, d.Discount, d.Sample = false, nil, false
  return true, "Commande payée. Livraison en route !"
 elseif action == "Price" then
  if value ~= 1 and value ~= 2 and value ~= 3 then return false, "Prix invalide." end
  d.PriceMode = value
 elseif action == "Upgrade" then
  local nextLevel = C.Levels[d.Level + 1]
  if not nextLevel then return false, "Ta tour est au niveau maximum." end
  if d.Sales < nextLevel.Sales then return false, "Il faut " .. nextLevel.Sales .. " ventes au total." end
  if d.Cash < nextLevel.Cost + E.OrderCost(d) then return false, "Garde " .. E.OrderCost(d) .. " $ pour ton prochain lot après les travaux." end
  d.Cash -= nextLevel.Cost d.Level += 1
  return true, "Nouveau bâtiment : " .. nextLevel.Name .. " !"
 elseif action == "Vehicle" then
  local car = C.Vehicles[value]
  if not car or value > d.Level then return false, "Développe ton entreprise pour débloquer ce véhicule." end
  if not d.Vehicles[tostring(value)] then
   -- Keep enough capital to place another order, avoiding an unrecoverable soft lock.
   if d.Cash < car.Cost + E.OrderCost(d) then return false, "Garde assez de caisse pour ton prochain lot : " .. E.OrderCost(d) .. " $." end
   d.Cash -= car.Cost d.Vehicles[tostring(value)] = true
  end
  d.ActiveVehicle = value
  return true, car.Name .. " t'attend à côté de ton entreprise."
 elseif action == "Luxury" then
  local item = C.Luxuries[value]
  if not item or item.Level > d.Level then return false, "Niveau d'entreprise insuffisant." end
  if d.Luxuries[tostring(value)] then return false, "Tu possèdes déjà cet objet." end
  if d.Cash < item.Cost + E.OrderCost(d) then return false, "Cet achat laisserait trop peu d'argent pour recommander." end
  d.Cash -= item.Cost d.Luxuries[tostring(value)] = true
  return true, item.Name .. " acheté avec la caisse de l'entreprise."
 elseif action == "Color" then
  if not C.Palette[value] then return false, "Couleur invalide." end
  d.Color = value
 else return false, "Action inconnue." end
 return true, "Modification enregistrée."
end
function E.Sale(d, bonus)
 if d.Stock < 1 then return 0 end
 local earned = math.floor(E.Price(d) * (bonus or 1))
 d.Stock -= 1 d.Cash += earned d.Sales += 1 d.Revenue += earned
 return earned
end
return E
