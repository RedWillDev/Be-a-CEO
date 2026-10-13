local C = require(script.Parent.Config)
local Info = {}
Info.BusBonus, Info.TouristBonus, Info.TrendBonus, Info.CollectiveBonus = 1.2, 2, 1.3, 1.5
function Info.Timer(seconds)
 local n = math.max(0, math.ceil(seconds))
 return string.format("%02d:%02d", math.floor(n / 60), n % 60)
end
function Info.Describe(event)
 local product = C.Products[event.Product] and C.Products[event.Product].Name or ""
 if event.Kind == "Bus de touristes" then
  return "Clients bonus : +20 % sur " .. product .. " • vacanciers portés : x2"
 elseif event.Kind == "Tendance surprise" then
  return product .. " : ventes locales +30 %"
 elseif event.Kind == "Commande collective" then
  return product .. " : contribution +50 % • " .. event.Units .. "/" .. event.Target .. " produits"
 end
 return "Prépare ta boutique • aucun bonus de vente actif"
end
return Info
