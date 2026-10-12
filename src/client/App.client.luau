local Players = game:GetService("Players")
local player = Players.LocalPlayer
local shared = game.ReplicatedStorage:WaitForChild("BeACEO")
local C = require(shared:WaitForChild("Config"))
local command = shared:WaitForChild("Command")
local state = shared:WaitForChild("State")
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.ZIndexBehavior = "CEOInterface", false, Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")
local ink, muted, mint = Color3.fromRGB(238, 240, 235), Color3.fromRGB(151, 168, 177), C.Palette[1]
local function round(obj, radius) local c = Instance.new("UICorner") c.CornerRadius, c.Parent = UDim.new(0, radius or 10), obj end
local function label(parent, text, size, pos, fontSize, color)
 local l = Instance.new("TextLabel") l.Size, l.Position, l.BackgroundTransparency = size, pos, 1
 l.Text, l.TextColor3, l.TextSize, l.Font = text, color or ink, fontSize or 15, Enum.Font.Gotham
 l.TextXAlignment, l.TextWrapped, l.Parent = Enum.TextXAlignment.Left, true, parent
 return l
end
local function button(parent, text, size, pos, callback, color)
 local b = Instance.new("TextButton") b.Size, b.Position = size, pos
 b.Text, b.TextSize, b.Font = text, 14, Enum.Font.GothamBold
 b.BackgroundColor3, b.TextColor3, b.AutoButtonColor = color or Color3.fromRGB(46, 64, 76), ink, true
 b.Parent = parent round(b, 8) b.Activated:Connect(callback) return b
end
local function fire(action, value) command:FireServer(action, value) end
local top = Instance.new("Frame") top.Size, top.Position, top.BackgroundColor3 = UDim2.new(1, -24, 0, 86), UDim2.fromOffset(12, 8), Color3.fromRGB(21, 31, 42) top.Parent = gui round(top)
label(top, "BE A CEO", UDim2.new(0.3, 0, 0, 29), UDim2.fromOffset(14, 6), 21, mint)
local cash = label(top, "Chargement…", UDim2.new(0.65, -15, 0, 29), UDim2.new(0.35, 0, 0, 6), 18)
local summary = label(top, "Ouvre ton entreprise", UDim2.new(1, -28, 0, 35), UDim2.fromOffset(14, 41), 13, muted)
local open = button(gui, "ENTREPRISE", UDim2.fromOffset(145, 42), UDim2.new(0, 12, 0, 104), function() end, Color3.fromRGB(31, 112, 94))
local home = button(gui, "Mon garage", UDim2.fromOffset(120, 42), UDim2.new(1, -132, 0, 104), function() fire("Home") end)
local panel = Instance.new("Frame") panel.Name = "Management" panel.Size, panel.Position = UDim2.new(0, 560, 0.68, 0), UDim2.new(0, 12, 0, 158) panel.BackgroundColor3 = Color3.fromRGB(24, 35, 47) panel.Parent = gui round(panel)
local constraint = Instance.new("UISizeConstraint") constraint.MaxSize, constraint.MinSize, constraint.Parent = Vector2.new(560, 610), Vector2.new(240, 130), panel
local function resize()
 local v = workspace.CurrentCamera.ViewportSize
 local compact = v.Y < 600
 local y = compact and 122 or 158
 top.Size = UDim2.new(1, -24, 0, compact and 66 or 86)
 summary.Position = UDim2.fromOffset(14, compact and 29 or 41)
 summary.TextSize = compact and 11 or 13
 open.Position = UDim2.fromOffset(12, compact and 78 or 104)
 home.Position = UDim2.new(1, -132, 0, compact and 78 or 104)
 panel.Position = UDim2.fromOffset(12, y)
 panel.Size = UDim2.new(0, math.min(560, v.X - 24), 0, math.max(130, math.min(610, v.Y - y - 72)))
end
resize() workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
local title = label(panel, "MARKETBRIDGE", UDim2.new(1, -60, 0, 30), UDim2.fromOffset(16, 10), 20, mint)
button(panel, "×", UDim2.fromOffset(32, 32), UDim2.new(1, -43, 0, 8), function() panel.Visible = false end)
open.Activated:Connect(function() panel.Visible = not panel.Visible end)
local tabs = Instance.new("Frame") tabs.Size, tabs.Position, tabs.BackgroundTransparency, tabs.Parent = UDim2.new(1, -24, 0, 35), UDim2.fromOffset(12, 49), 1, panel
local scroll = Instance.new("ScrollingFrame") scroll.Size, scroll.Position = UDim2.new(1, -24, 1, -100), UDim2.fromOffset(12, 92)
scroll.BackgroundTransparency, scroll.BorderSizePixel, scroll.ScrollBarThickness = 1, 0, 4
scroll.AutomaticCanvasSize, scroll.CanvasSize, scroll.Parent = Enum.AutomaticSize.Y, UDim2.new(), panel
local list = Instance.new("UIListLayout") list.Padding, list.SortOrder, list.Parent = UDim.new(0, 8), Enum.SortOrder.LayoutOrder, scroll
local toast = label(gui, "", UDim2.new(1, -40, 0, 54), UDim2.new(0, 20, 1, -65), 16)
toast.BackgroundColor3, toast.BackgroundTransparency, toast.TextXAlignment, toast.Visible = Color3.fromRGB(29, 53, 61), 0.06, Enum.TextXAlignment.Center, false round(toast)
local latest, currentTab, toastId = nil, "Marché", 0
local liveLabels = {}
local function notice(message)
 toastId += 1 local id = toastId toast.Text, toast.Visible = message, true
 task.delay(5, function() if toastId == id then toast.Visible = false end end)
end
local function row(height)
 local r = Instance.new("Frame") r.Size, r.BackgroundColor3, r.Parent = UDim2.new(1, -5, 0, height), Color3.fromRGB(32, 46, 59), scroll round(r, 8) return r
end
local function textRow(text, height)
 local r = row(height or 54) return label(r, text, UDim2.new(1, -24, 1, -12), UDim2.fromOffset(12, 6), 14, muted)
end
local function card(name, detail, actionText, callback, selected)
 local r = row(106)
 label(r, name, UDim2.new(1, -20, 0, 23), UDim2.fromOffset(10, 6), 17, selected and mint or ink)
 label(r, detail, UDim2.new(1, -20, 0, 31), UDim2.fromOffset(10, 29), 12, muted)
 button(r, actionText, UDim2.new(1, -20, 0, 32), UDim2.fromOffset(10, 65), callback, selected and Color3.fromRGB(36, 111, 92) or nil)
end
local function render()
 if not latest then return end
 local d = latest.Data
 liveLabels = {}
 for _, child in ipairs(scroll:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
 title.Text = currentTab == "Marché" and "MARKETBRIDGE" or currentTab == "Entreprise" and "TA MARQUE, TA VILLE" or currentTab == "Objectifs" and "OBJECTIFS & ÉVÉNEMENTS" or "LA VIE DE CEO"
 if currentTab == "Marché" then
  liveLabels.guide = textRow("", 65)
  local quickOrder = row(52)
  liveLabels.order = button(quickOrder, "Commander", UDim2.new(1, -20, 0, 36), UDim2.fromOffset(10, 8), function() fire("Order") end, Color3.fromRGB(31, 112, 94))
  for i, product in ipairs(C.Products) do card(product.Name, "Base : " .. product.Cost .. " $ / unité • vente conseillée : " .. product.Price .. " $", d.Product == i and "Produit en vitrine ✓" or "Choisir ce produit", function() fire("Product", i) end, d.Product == i) end
  textRow("Fournisseurs • compare coût, qualité et délai", 40)
  for i, supplier in ipairs(C.Suppliers) do card(supplier.Name, supplier.Detail .. " • " .. supplier.Delay .. " s • qualité " .. supplier.Quality, d.Supplier == i and "Fournisseur sélectionné ✓" or "Choisir", function() fire("Supplier", i) end, d.Supplier == i) end
  card("Accord de volume", "10 % de remise sur un lot de 10. Un seul accord par commande.", d.Negotiated and "Accord déjà conclu ✓" or "Négocier −10 %", function() fire("Negotiate", "Volume") end, d.Negotiated)
  card("Relation fournisseur", (d.SupplierOrders and (d.SupplierOrders[tostring(d.Supplier)] or 0) or 0) .. " commandes chez ce fournisseur. Après 3 : remise fidélité de 15 %.", "Négocier la fidélité", function() fire("Negotiate", "Loyalty") end)
  card("Contrôle qualité", "Renonce à la remise pour gagner +0,2 de qualité sur le prochain lot.", "Choisir la qualité", function() fire("Negotiate", "Sample") end)
  local r = row(52)
  button(r, "Commander le lot sélectionné", UDim2.new(1, -20, 0, 36), UDim2.fromOffset(10, 8), function() fire("Order") end, Color3.fromRGB(31, 112, 94))
  textRow("Au départ : porte les colis de la porte au comptoir, puis utilise la caisse pour servir les clients locaux. Les employés automatisent ces tâches. Prix, qualité et tendance attirent les clients.", 88)
  for i, name in ipairs({"Économique • ventes rapides", "Équilibré • prix conseillé", "Premium • marge élevée"}) do
   local r2 = row(42) button(r2, (d.PriceMode == i and "✓ " or "") .. name, UDim2.new(1, -12, 0, 34), UDim2.fromOffset(6, 4), function() fire("Price", i) end)
  end
  card("Liquider le stock", "Récupère 50 % du coût de base des produits pour changer de gamme. Ne compte pas comme vente.", "Liquider tout le stock", function() fire("Liquidate") end)
 elseif currentTab == "Entreprise" then
  liveLabels.progress = textRow("", 75)
  local nextLevel = C.Levels[d.Level + 1]
  if nextLevel then card("Passer à " .. nextLevel.Name, nextLevel.Cost .. " $ • " .. nextLevel.Sales .. " ventes cumulées requises", "Agrandir mon entreprise", function() fire("Upgrade") end) end
  textRow("Équipe • recrutement et formations payés une fois, sans salaire récurrent pour cette version. Trois niveaux par poste.", 70)
  for i, role in ipairs(latest.StaffRoles or {}) do
   local rank = d.Staff and d.Staff[role.Key] or 0
   local effects = {"Encaisse les clients locaux ; accélère aux niveaux 2 et 3.", "Va chercher et porte les colis. Départ après 3 / 2 / 1 secondes ; marche plus vite à chaque niveau. Stock crédité au retour.", "Commande quand le stock descend à 3 / 4 / 5 produits.", "Recrute et forme les 3 autres postes jusqu'à son propre niveau."}
   card(role.Name .. " • niveau " .. rank .. "/3", "Entreprise " .. role.Level .. " • " .. effects[i], rank == 3 and "Niveau maximum" or ((rank == 0 and "Recruter : " or "Former : ") .. role.Cost * (rank + 1) .. " $"), function() fire("Hire", i) end, rank > 0)
  end
  card("Réapprovisionnement automatique", "Responsable commandes requis. Dépense la caisse au prix normal du lot tant que cette option reste active.", d.AutoOrder and "Désactiver" or "Activer", function() fire("AutoOrder") end, d.AutoOrder)
  card("Déléguer au gérant", "Sur accord : recrute et améliore l'équipe toutes les 20 s. Préserve deux lots de marchandises. N'achète jamais de bâtiment ni de luxe.", d.ManagerEnabled and "Suspendre le gérant" or "Autoriser la gestion", function() fire("Manager") end, d.ManagerEnabled)
  card("Rivalité de livraison • test Studio", "Vol entre volontaires niveau 2+. Colis protégé 20 s ; assurance de 50 % en cas de perte. Désactivé sur les serveurs publiés.", d.Rivalry and "Désactiver la rivalité" or "Participer à la rivalité", function() fire("Rivalry") end, d.Rivalry)
  card("Campagne de quartier", "100 $ • visibilité accrue pendant 120 s pour les clients disputés. Aucun revenu garanti.", "Lancer la campagne", function() fire("Marketing") end)
  textRow("Identité de marque • personnalisation gratuite", 44)
  for i in ipairs(C.Palette) do local r = row(42) button(r, "Palette " .. i .. (d.Color == i and " ✓" or ""), UDim2.new(1, -12, 0, 34), UDim2.fromOffset(6, 4), function() fire("Color", i) end, C.Palette[i]) end
  textRow("Sur la place au nord : accompagne le client VIP jusqu'à ton comptoir pour une vente x3. Tu marches plus lentement et il faut du stock. Entrer dans une voiture abandonne le VIP.", 100)
  textRow("Vacanciers : pendant le bus, accompagne un touriste à ta boutique pour une vente x2. Un seul colis ou client porté à la fois. Voiture, mort ou téléportation interrompent le portage.", 95)
  local r = row(42) button(r, "Déposer le colis ou le client", UDim2.new(1, -12, 0, 34), UDim2.fromOffset(6, 4), function() fire("Drop") end)
 elseif currentTab == "Objectifs" then
  local p = latest.Progression
  if not p then return end
  liveLabels.event = textRow("", 100)
  card("Commande collective", "Pendant l'événement : contribue jusqu'à 5 produits demandés. Chaque produit est payé 150 % du prix de vente, immédiatement.", "Fournir jusqu'à 5 produits", function() fire("Contribute") end)
  liveLabels.reputation = textRow("", 70)
  liveLabels.board = textRow("", 155)
  card("Calendrier sans pénalité", "Prochain cadeau : jour " .. p.GiftDay .. " / 7. Aucun acquis perdu. Renouvellement à minuit UTC.", p.GiftAvailable and "Recevoir mon cadeau" or "Cadeau reçu aujourd'hui ✓", function() fire("DailyGift") end)
  textRow("Parcours entrepreneur • récompenses uniques", 42)
  for _, m in ipairs(p.Missions) do
   card(m.Name, m.Progress .. " / " .. m.Target .. " • récompense " .. m.Reward .. " $", m.Claimed and "Reçu ✓" or "Recevoir la récompense", function() fire("Mission", m.Id) end, m.Claimed)
  end
  textRow("Missions du jour • progression sauvegardée", 42)
  for _, m in ipairs(p.Daily) do
   card(m.Name, m.Progress .. " / " .. m.Target .. " • récompense " .. m.Reward .. " $", m.Claimed and "Reçu ✓" or "Recevoir la récompense", function() fire("DailyMission", m.Id) end, m.Claimed)
  end
  textRow("Hors ligne : le stock existant peut se vendre à moitié prix, une unité toutes les 2 minutes, sur 4 h maximum. Pas de production gratuite ni de réapprovisionnement hors ligne.", 90)
 else
  textRow("Tes achats personnels sont payés par la caisse de l'entreprise. Une réserve pour le prochain lot est conservée. Tout utilise des dollars fictifs du jeu.", 85)
  for i, car in ipairs(C.Vehicles) do
   local owned = d.Vehicles[tostring(i)]
   card(car.Name .. " • classe " .. i, car.Cost .. " $ • " .. C.Levels[i].Name .. " requis • vitesse " .. car.Speed, owned and "Sortir du garage" or d.Level < i and "Verrouillé • entreprise niveau " .. i or "Acheter avec la caisse", function() fire("Vehicle", i) end, owned)
  end
  textRow("Conduite : monte sur le siège de ta voiture. Utilise les contrôles Roblox (ZQSD/WASD ou joystick). Saute pour descendre.", 74)
  for i, item in ipairs(C.Luxuries) do card(item.Name, item.Cost .. " $ • entreprise niveau " .. item.Level .. " • décoration personnelle exposée", d.Luxuries[tostring(i)] and "Possédé ✓" or "Acheter avec la caisse", function() fire("Luxury", i) end, d.Luxuries[tostring(i)]) end
 end
end
for i, name in ipairs({"Marché", "Entreprise", "Lifestyle", "Objectifs"}) do
 local tab = button(tabs, name, UDim2.new(1/4, -5, 1, 0), UDim2.new((i-1)/4, 0, 0, 0), function() currentTab = name scroll.CanvasPosition = Vector2.zero render() end)
 tab.TextScaled = true local limit = Instance.new("UITextSizeConstraint") limit.MinTextSize, limit.MaxTextSize, limit.Parent = 9, 14, tab
end
state.OnClientEvent:Connect(function(snapshot)
 local previous = latest latest = snapshot
 local d = snapshot.Data
 cash.Text = string.format("%d $  •  %s", d.Cash, C.Levels[d.Level].Name)
 summary.Text = string.format("Stock %d • %d ventes • File %d/3 • parcelle %d\nTendance : %s (%ds) • %s", d.Stock, d.Sales, snapshot.QueueCount or 0, snapshot.Plot, C.Products[snapshot.Trend].Name, snapshot.TrendSeconds, snapshot.Saving)
 local changed = not previous
 if previous then
  for _, key in ipairs({"Product", "Supplier", "PriceMode", "Level", "Color", "Negotiated", "ActiveVehicle", "AutoOrder", "DailyClaim", "ManagerEnabled", "Rivalry"}) do if previous.Data[key] ~= d[key] then changed = true end end
  for key, rank in pairs(d.Staff or {}) do if not previous.Data.Staff or previous.Data.Staff[key] ~= rank then changed = true end end
  if currentTab == "Objectifs" and (previous.Data.Sales ~= d.Sales or snapshot.Message or previous.Data.Daily.Day ~= d.Daily.Day) then changed = true end
  for key, value in pairs(d.Vehicles) do if previous.Data.Vehicles[key] ~= value then changed = true end end
  for key, value in pairs(d.Luxuries) do if previous.Data.Luxuries[key] ~= value then changed = true end end
 end
 if changed then render() end
 if liveLabels.guide then
  liveLabels.guide.Text = d.Parcel and "02 / RÉCEPTION\nPrends le colis devant ta porte et porte-le jusqu'au comptoir." or snapshot.Waiting and "03 / PREMIÈRE VENTE\nUn client attend : approche de la caisse et utilise Encaisser." or d.Sales == 0 and "01 / COMMANDER\nChoisis ton produit, négocie puis commande 10 unités." or "04 / DÉVELOPPER\nRecrute ton équipe dans Entreprise et récupère tes récompenses dans Objectifs."
 end
 if liveLabels.order then liveLabels.order.Text = d.Parcel and "Colis devant la porte • à réceptionner" or d.Order and ("Livraison dans " .. d.Order.Remaining .. " s…") or ("Commander 10 unités • " .. math.ceil(C.Products[d.Product].Cost * 10 * C.Suppliers[d.Supplier].Factor * (d.Negotiated and (1 - (d.Discount or 0.1)) or 1)) .. " $") end
 if liveLabels.event then local e = snapshot.Event liveLabels.event.Text = e.Kind .. " • " .. C.Products[e.Product].Name .. "\nFin dans " .. math.max(0, e.Ends - os.time()) .. " s • collectif " .. e.Units .. "/" .. e.Target .. "\nTouristes : +20 % ; tendance surprise : +30 % sur les ventes locales concernées." end
 if liveLabels.reputation then liveLabels.reputation.Text = "Réputation : " .. snapshot.Progression.Reputation .. "/100 • clients disputés gagnés : " .. d.Disputed .. "\nPublicité restante : " .. snapshot.Progression.Marketing .. " s. Les clients privilégient tour à tour qualité, tendance ou prix." end
 if liveLabels.board then
  local lines = {"Part des clients disputés (joueurs présents, session) : " .. snapshot.MarketShare .. "%"}
  for i, entry in ipairs(snapshot.Board) do table.insert(lines, i .. ". " .. entry.Name .. " • " .. entry.Wins .. " clients • " .. C.Levels[entry.Level].Name) end
  liveLabels.board.Text = table.concat(lines, "\n")
 end
 if liveLabels.progress then liveLabels.progress.Text = "Entreprise : " .. C.Levels[d.Level].Name .. "\n" .. d.Sales .. " ventes • chiffre d'affaires " .. d.Revenue .. " $\nLes achats personnels ne comptent pas comme investissement." end
 if snapshot.Message == "OPEN_MARKET" then currentTab = "Marché" panel.Visible = true render()
 elseif snapshot.Message then notice(snapshot.Message) end
end)
fire("Ready")
