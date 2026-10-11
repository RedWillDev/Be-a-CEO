local S = {}
S.Roles = {
 {Key = "Cashier", Name = "Caissier", Level = 1, Cost = 120},
 {Key = "Receiver", Name = "Réceptionnaire", Level = 1, Cost = 150},
 {Key = "Buyer", Name = "Responsable commandes", Level = 2, Cost = 250},
 {Key = "Manager", Name = "Gérant", Level = 4, Cost = 1200},
}
function S.Init(d)
 d.Staff = d.Staff or {Cashier = 0, Receiver = 0, Buyer = 0, Manager = 0}
 for _, role in ipairs(S.Roles) do d.Staff[role.Key] = d.Staff[role.Key] or 0 end
end
function S.Hire(d, id, reserve)
 S.Init(d)
 local role = S.Roles[id]
 if not role then return false, "Poste inconnu." end
 local rank = d.Staff[role.Key]
 if d.Level < role.Level then return false, "Entreprise niveau " .. role.Level .. " requis." end
 if rank >= 3 then return false, "Employé au niveau maximum." end
 local cost = role.Cost * (rank + 1)
 if d.Cash < cost + reserve then return false, "Garde la réserve pour les marchandises." end
 d.Cash -= cost d.Staff[role.Key] += 1
 return true, role.Name .. " niveau " .. (rank + 1) .. " !"
end
function S.Manage(d, reserve)
 S.Init(d)
 if not d.ManagerEnabled or d.Staff.Manager == 0 then return false end
 -- Explicitly enabled by player. Never buys buildings, luxuries or another manager.
 -- Keep two orders in reserve; deterministic priority: caisse, réception, achats.
 for rank = 1, math.min(3, d.Staff.Manager) do
  for id = 1, 3 do
   if d.Staff[S.Roles[id].Key] < rank then return S.Hire(d, id, reserve * 2) end
  end
 end
 return false
end
return S
