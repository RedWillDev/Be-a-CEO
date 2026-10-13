-- All clocks and action arguments are supplied by the server, never the client.
local C = require(game.ReplicatedStorage.BeACEO.Config)
local P = {}
P.Missions = {
 {Name = "Premières ventes", Field = "Sales", Target = 5, Reward = 100},
 {Name = "Une vraie boutique", Field = "Level", Target = 2, Reward = 200},
 {Name = "La clientèle grandit", Field = "Sales", Target = 35, Reward = 350},
 {Name = "Un siège à ton nom", Field = "Level", Target = 4, Reward = 750},
 {Name = "L'empire", Field = "Level", Target = 5, Reward = 1500},
}
function P.Init(d, now)
 d.Claims = d.Claims or {}
 d.SupplierOrders = d.SupplierOrders or {}
 d.Reputation = d.Reputation or 0
 d.Disputed = d.Disputed or 0
 d.VIPSales = d.VIPSales or 0
 d.DailyCount = d.DailyCount or 0
 d.DailyClaim = d.DailyClaim or -1
 d.MarketingUntil = d.MarketingUntil or 0
 d.LastSeen = d.LastSeen or now
 local day = math.floor(now / 86400)
 if not d.Daily or d.Daily.Day ~= day then
  d.Daily = {Day = day, Sales = 0, Orders = 0, VIP = 0, Claims = {}}
 end
end
function P.Offline(d, now, sale)
 P.Init(d, now)
 if not d.Staff or (d.Staff.Cashier or 0) < 1 then d.LastSeen = now return 0, 0 end
 local elapsed = math.clamp(now - d.LastSeen, 0, 4 * 3600)
 -- Only sell existing inventory. No free production, no double-counted elapsed time.
 local units = math.min(d.Stock, math.floor(elapsed / 120))
 local earned = 0
 for _ = 1, units do earned += sale(d, 0.5) end
 d.LastSeen = now
 return earned, units
end
function P.OnSale(d, kind, now)
 P.Init(d, now)
 d.Daily.Sales += 1
 d.Reputation = math.min(100, d.Reputation + (d.Quality >= 1 and 0.3 or 0.1))
 if kind == "VIP" then d.VIPSales += 1 d.Daily.VIP += 1 end
 if kind == "Disputed" then d.Disputed += 1 end
end
function P.OnOrder(d, now)
 P.Init(d, now)
 d.Daily.Orders += 1
 local key = tostring(d.Supplier)
 d.SupplierOrders[key] = (d.SupplierOrders[key] or 0) + 1
end
function P.Action(d, action, value, now, orderCost)
 P.Init(d, now)
 if action == "Mission" then
  local m = P.Missions[value]
  if not m or d.Claims[tostring(value)] then return false, "Objectif déjà reçu ou inconnu." end
  if (d[m.Field] or 0) < m.Target then return false, "Objectif pas encore terminé." end
  d.Claims[tostring(value)] = true d.Cash += m.Reward
  return true, m.Name .. " : +" .. m.Reward .. " $ !"
 elseif action == "DailyGift" then
  local day = math.floor(now / 86400)
  if d.DailyClaim >= day then return false, "Cadeau déjà reçu. Renouvellement à minuit UTC." end
  local reward = 75 + (d.DailyCount % 7) * 25
  d.DailyClaim = day d.DailyCount += 1 d.Cash += reward
  return true, "Jour " .. ((d.DailyCount - 1) % 7 + 1) .. " : +" .. reward .. " $ ! Aucun jour manqué ne remet ton calendrier à zéro."
 elseif action == "DailyMission" then
  local specs = {{"Sales", 15, 150}, {"Orders", 3, 100}, {"VIP", 1, 125}}
  local m = specs[value]
  if not m or d.Daily.Claims[tostring(value)] then return false, "Mission déjà reçue ou inconnue." end
  if d.Daily[m[1]] < m[2] then return false, "Continue : cet objectif quotidien n'est pas terminé." end
  d.Daily.Claims[tostring(value)] = true d.Cash += m[3]
  return true, "Mission quotidienne : +" .. m[3] .. " $ !"
 elseif action == "Marketing" then
  if d.MarketingUntil > now then return false, "Ta campagne est encore active." end
  if d.Cash < 100 + orderCost then return false, "Préserve la réserve de ton prochain lot." end
  d.Cash -= 100 d.MarketingUntil = now + 120
  return true, "Campagne lancée : bonus de visibilité pendant 120 secondes. Ventes non garanties."
 elseif action == "AutoOrder" then
  if d.Level < 2 then return false, "Le réapprovisionnement automatique se débloque à la boutique." end
  d.AutoOrder = not d.AutoOrder
  return true, d.AutoOrder and ("Commandes automatiques reprises : un lot quand il reste " .. (2 + (d.Staff and d.Staff.Buyer or 1)) .. " produits ou moins.") or "Commandes automatiques en pause. Tu peux toujours commander toi-même."
 elseif action == "Liquidate" then
  if d.Stock < 1 then return false, "Aucun stock à liquider." end
  local amount = math.floor(d.Stock * C.Products[d.Product].Cost * 0.5)
  d.Stock = 0 d.Cash += amount
  return true, "Stock liquidé : +" .. amount .. " $. Ce remboursement ne compte pas comme vente."
 end
 return nil
end
function P.View(d, now)
 P.Init(d, now)
 local result = {Missions = {}, Daily = {}, Reputation = math.floor(d.Reputation), Disputed = d.Disputed,
  GiftAvailable = d.DailyClaim < math.floor(now / 86400), GiftDay = d.DailyCount % 7 + 1,
  ResetIn = 86400 - now % 86400, Marketing = math.max(0, d.MarketingUntil - now)}
 for i, m in ipairs(P.Missions) do
  table.insert(result.Missions, {Id = i, Name = m.Name, Progress = math.min(d[m.Field] or 0, m.Target), Target = m.Target, Reward = m.Reward, Claimed = d.Claims[tostring(i)] == true})
 end
 for i, m in ipairs({{"Vendre 15 produits", "Sales", 15, 150}, {"Commander 3 lots", "Orders", 3, 100}, {"Accueillir un VIP", "VIP", 1, 125}}) do
  table.insert(result.Daily, {Id = i, Name = m[1], Progress = math.min(d.Daily[m[2]], m[3]), Target = m[3], Reward = m[4], Claimed = d.Daily.Claims[tostring(i)] == true})
 end
 return result
end
return P
