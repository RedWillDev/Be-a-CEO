local C = require(script.Parent.Config)
local Guide = {}
function Guide.Text(snapshot)
 local d = snapshot.Data
 local staff = d.Staff or {}
 if snapshot.Carrying then return "Ramène ce que tu portes dans ta boutique." end
 if snapshot.Waiting then
  if (staff.Cashier or 0) == 0 then return "Un client attend ! Va à la caisse et appuie sur Encaisser." end
  return "Ton caissier s'occupe des clients. Tu peux explorer la ville !"
 end
 if d.Parcel then
  return (staff.Receiver or 0) > 0 and "Ton réceptionnaire va chercher le colis pour toi." or "Prends le colis devant ta porte et ramène-le dans ta boutique."
 end
 if d.Order then return "Ta livraison arrive. Prépare-toi à recevoir le colis !" end
 if d.Stock == 0 then
  local cost = math.ceil(C.Products[d.Product].Cost * 10 * C.Suppliers[d.Supplier].Factor * (d.Negotiated and (1 - (d.Discount or 0.1)) or 1))
  if d.Cash < cost then return "Pas assez d'argent ? Regarde les cadeaux et récompenses dans MISSIONS." end
  if (staff.Buyer or 0) > 0 and d.AutoOrder then return "Ton responsable va commander de nouveaux produits." end
  return "Ouvre BOUTIQUE et commande 10 produits pour remplir tes rayons."
 end
 if d.Sales == 0 then return "Les clients choisissent un produit, puis viennent à la caisse." end
 if (staff.Cashier or 0) == 0 then return "Recrute un caissier dans ENTREPRISE : il encaissera pour toi." end
 if (staff.Receiver or 0) == 0 then return "Recrute un réceptionnaire : il ira chercher tes colis." end
 if d.Level < 2 then return "Améliore ton entreprise pour agrandir tes rayons !" end
 if (staff.Buyer or 0) == 0 then return "Recrute un responsable commandes pour remplir le stock tout seul." end
 if not d.AutoOrder then return "Commandes en pause : reprends-les dans ENTREPRISE quand tu veux." end
 return "Ton équipe travaille ! Explore la ville ou améliore ta boutique."
end
return Guide
