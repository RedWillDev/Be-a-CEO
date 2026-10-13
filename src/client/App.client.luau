local Players = game:GetService("Players")
local player = Players.LocalPlayer
local shared = game.ReplicatedStorage:WaitForChild("BeACEO")
local C = require(shared:WaitForChild("Config"))
local Guide = require(shared:WaitForChild("NextStep"))
local command = shared:WaitForChild("Command")
local state = shared:WaitForChild("State")
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.ZIndexBehavior = "CEOInterface", false, Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")
local ink, muted, mint = Color3.fromRGB(248, 250, 255), Color3.fromRGB(183, 199, 222), Color3.fromRGB(70, 224, 151)
local blue, navy = Color3.fromRGB(58, 119, 244), Color3.fromRGB(24, 34, 58)
local latest, currentTab, toastId = nil, "Marché", 0
local advanced, liquidation = false, nil
local liveLabels, tabButtons, navigation = {}, {}, {}
local function round(obj, radius) local c = Instance.new("UICorner") c.CornerRadius, c.Parent = UDim.new(0, radius or 16), obj end
local function outline(obj, color)
 local s = Instance.new("UIStroke") s.Color, s.Thickness, s.Transparency, s.Parent = color or Color3.fromRGB(77, 98, 137), 1.5, 0.35, obj
end
local function label(parent, text, size, pos, fontSize, color)
 local l = Instance.new("TextLabel") l.Size, l.Position, l.BackgroundTransparency = size, pos, 1
 l.Text, l.TextColor3, l.TextSize, l.Font = text, color or ink, fontSize or 15, Enum.Font.GothamMedium
 l.TextXAlignment, l.TextWrapped, l.Parent = Enum.TextXAlignment.Left, true, parent
 return l
end
local function button(parent, text, size, pos, callback, color)
 local b = Instance.new("TextButton") b.Size, b.Position = size, pos
 b.Text, b.TextSize, b.Font, b.TextWrapped = text, 15, Enum.Font.GothamBold, true
 b.BackgroundColor3, b.TextColor3, b.AutoButtonColor = color or blue, ink, true
 b.Parent = parent round(b, 12) outline(b)
 b.Activated:Connect(callback) return b
end
local function fire(action, value) command:FireServer(action, value) end
local top = Instance.new("Frame") top.Name = "Stats" top.BackgroundTransparency = 1 top.Parent = gui
local function stat(name, caption, color, fraction)
 local frame = Instance.new("Frame") frame.Name = name frame.BackgroundColor3 = navy
 frame.Position, frame.Size, frame.Parent = UDim2.fromScale(fraction, 0), UDim2.new(1/3, -6, 1, 0), top
 round(frame, 16) outline(frame, color)
 label(frame, caption, UDim2.new(1, -20, 0, 18), UDim2.fromOffset(10, 6), 11, color)
 local value = label(frame, "…", UDim2.new(1, -20, 0, 29), UDim2.fromOffset(10, 24), 21)
 value.Font = Enum.Font.GothamBold value.TextScaled = true
 local limit = Instance.new("UITextSizeConstraint") limit.MinTextSize, limit.MaxTextSize, limit.Parent = 12, 23, value
 return value
end
local cash = stat("Cash", "$  ARGENT", mint, 0)
local level = stat("Level", "★  ENTREPRISE", Color3.fromRGB(255, 208, 92), 1/3)
local stock = stat("Stock", "▣  STOCK", Color3.fromRGB(115, 185, 255), 2/3)
local nav = Instance.new("Frame") nav.Name, nav.BackgroundTransparency, nav.Parent = "Navigation", 1, gui
local shade = Instance.new("TextButton") shade.Name = "ModalBackdrop" shade.Text = ""
shade.Size, shade.BackgroundColor3, shade.BackgroundTransparency = UDim2.fromScale(1, 1), Color3.new(), 0.4
shade.AutoButtonColor, shade.Visible, shade.Parent = false, false, gui
local panel = Instance.new("Frame") panel.Name, panel.BackgroundColor3, panel.Visible, panel.Parent = "Management", navy, false, gui
round(panel, 20) outline(panel)
local title = label(panel, "BOUTIQUE", UDim2.new(1, -88, 0, 38), UDim2.fromOffset(20, 10), 23)
title.Font = Enum.Font.GothamBlack
local tabs = Instance.new("Frame") tabs.Size, tabs.Position, tabs.BackgroundTransparency, tabs.Parent = UDim2.new(1, -32, 0, 42), UDim2.fromOffset(16, 62), 1, panel
local scroll = Instance.new("ScrollingFrame") scroll.Size, scroll.Position = UDim2.new(1, -32, 1, -126), UDim2.fromOffset(16, 114)
scroll.BackgroundTransparency, scroll.BorderSizePixel, scroll.ScrollBarThickness = 1, 0, 5
scroll.ScrollBarImageColor3 = mint
scroll.AutomaticCanvasSize, scroll.CanvasSize, scroll.Parent = Enum.AutomaticSize.Y, UDim2.new(), panel
local list = Instance.new("UIListLayout") list.Padding, list.SortOrder, list.Parent = UDim.new(0, 10), Enum.SortOrder.LayoutOrder, scroll
local objective = Instance.new("Frame") objective.Name, objective.BackgroundColor3, objective.Parent = "CurrentObjective", navy, gui
round(objective, 14) outline(objective, mint)
label(objective, "PROCHAINE ÉTAPE", UDim2.new(1, -24, 0, 17), UDim2.fromOffset(12, 6), 10, mint)
local objectiveText = label(objective, "Ouvre la boutique pour commander.", UDim2.new(1, -24, 0, 35), UDim2.fromOffset(12, 23), 14)
local drop = button(gui, "↓  DÉPOSER", UDim2.fromOffset(150, 44), UDim2.new(), function() fire("Drop") end, Color3.fromRGB(177, 81, 73))
drop.Visible = false
local toast = label(gui, "", UDim2.new(), UDim2.new(), 14)
toast.BackgroundColor3, toast.BackgroundTransparency, toast.TextXAlignment, toast.Visible = Color3.fromRGB(35, 70, 99), 0, Enum.TextXAlignment.Center, false
round(toast, 12) outline(toast)
local padding = Instance.new("UIPadding") padding.PaddingLeft, padding.PaddingRight, padding.Parent = UDim.new(0, 12), UDim.new(0, 12), toast
local function setPanel(visible)
 panel.Visible, shade.Visible, nav.Visible = visible, visible, not visible
 objective.Visible = not visible
 drop.Visible = not visible and latest ~= nil and latest.Carrying == true
end
button(panel, "×", UDim2.fromOffset(44, 44), UDim2.new(1, -56, 0, 10), function() setPanel(false) end, Color3.fromRGB(179, 68, 84))
shade.Activated:Connect(function() setPanel(false) end)
local function resize()
 local camera = workspace.CurrentCamera if not camera then return end
 local viewport = camera.ViewportSize
 local v = Vector2.new(viewport.X, math.max(240, viewport.Y - 60))
 local small, landscape = v.X < 700, v.Y < 500
 local width = math.min(620, v.X - 20)
 top.Size, top.Position = UDim2.fromOffset(width, 62), UDim2.new(0.5, -width/2, 0, 8)
 local panelY = landscape and 78 or 134
 panel.Size = UDim2.fromOffset(math.min(650, v.X - 24), math.max(150, v.Y - panelY - 32))
 panel.Position = UDim2.new(0.5, -math.min(650, v.X - 24)/2, 0, panelY)
 nav.Size, nav.Position = landscape and UDim2.fromOffset(98, 210) or UDim2.fromOffset(small and 104 or 130, 290), UDim2.fromOffset(10, 82)
 for i, b in ipairs(navigation) do
  b.Size = UDim2.new(1, 0, 0, landscape and 36 or small and 44 or 50)
  b.Position = UDim2.fromOffset(0, (i-1) * (landscape and 41 or small and 50 or 58))
  b.TextSize = small and 12 or 14
 end
 if landscape then
  nav.Size, nav.Position = UDim2.fromOffset(width, 42), UDim2.new(0.5, -width/2, 0, 80)
  for i, b in ipairs(navigation) do b.Size, b.Position, b.TextSize = UDim2.new(0.2, -5, 1, 0), UDim2.new((i-1)/5, 0, 0, 0), 12 end
 end
 local ow = math.min(450, v.X - (landscape and 260 or 24))
 objective.Size = UDim2.fromOffset(ow, 66)
 objective.Position = UDim2.new(0.5, -ow/2, 1, small and -165 or -82)
 drop.Position = UDim2.new(0.5, -75, 1, small and -215 or -134)
 toast.Size = UDim2.fromOffset(math.min(600, v.X - 24), 48)
 toast.Position = UDim2.new(0.5, -math.min(600, v.X - 24)/2, 0, landscape and 8 or 78)
end
local cameraConnection
local function watchCamera()
 if cameraConnection then cameraConnection:Disconnect() end
 if workspace.CurrentCamera then cameraConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
 resize()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
watchCamera()
local function notice(message)
 toastId += 1 local id = toastId toast.Text, toast.Visible = message, true
 task.delay(4, function() if toastId == id then toast.Visible = false end end)
end
local function row(height)
 local r = Instance.new("Frame") r.Size, r.BackgroundColor3, r.Parent = UDim2.new(1, -5, 0, height), Color3.fromRGB(34, 48, 76), scroll round(r, 12) return r
end
local function textRow(text, height)
 local r = row(height or 54) return label(r, text, UDim2.new(1, -24, 1, -12), UDim2.fromOffset(12, 6), 14, muted)
end
local function card(name, detail, actionText, callback, selected)
 local narrow = panel.AbsoluteSize.X < 430
 local detailHeight = narrow and 80 or 48
 local r = row(94 + detailHeight)
 label(r, name, UDim2.new(1, -24, 0, 30), UDim2.fromOffset(12, 8), 17, selected and mint or ink)
 label(r, detail, UDim2.new(1, -24, 0, detailHeight), UDim2.fromOffset(12, 40), 13, muted)
 button(r, actionText, UDim2.new(1, -24, 0, 42), UDim2.fromOffset(12, 44 + detailHeight), callback, selected and Color3.fromRGB(36, 111, 92) or nil)
end
local function render()
 if not latest then return end
 local d = latest.Data
 liveLabels = {}
 for _, child in ipairs(scroll:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
 title.Text = currentTab == "Marché" and "BOUTIQUE" or currentTab == "Entreprise" and "MON ENTREPRISE" or currentTab == "Objectifs" and "MISSIONS & CADEAUX" or "GARAGE & OBJETS"
 for name, tab in pairs(tabButtons) do tab.BackgroundColor3 = name == currentTab and blue or Color3.fromRGB(45, 60, 87) end
 if currentTab == "Marché" then
  liveLabels.guide = textRow("", 65)
  liveLabels.marketInfo = textRow("", 64)
  local quickOrder = row(52)
  liveLabels.order = button(quickOrder, "Commander", UDim2.new(1, -20, 0, 36), UDim2.fromOffset(10, 8), function() fire("Order") end, Color3.fromRGB(31, 112, 94))
  for i, product in ipairs(C.Products) do card(product.Name, "Base : " .. product.Cost .. " $ / unité • vente conseillée : " .. product.Price .. " $", d.Product == i and "Produit en vitrine ✓" or "Choisir ce produit", function() fire("Product", i) end, d.Product == i) end
  local options = row(48)
  button(options, advanced and "Masquer les réglages avancés" or "Réglages avancés : fournisseurs, remises et prix", UDim2.new(1, -20, 0, 36), UDim2.fromOffset(10, 6), function() advanced = not advanced liquidation = nil render() end)
  if advanced then
  textRow("Fournisseurs • compare coût, qualité et délai", 40)
  for i, supplier in ipairs(C.Suppliers) do card(supplier.Name, supplier.Detail .. " • " .. supplier.Delay .. " s • qualité " .. supplier.Quality, d.Supplier == i and "Fournisseur sélectionné ✓" or "Choisir", function() fire("Supplier", i) end, d.Supplier == i) end
  card("Accord de volume", "10 % de remise sur un lot de 10. Un seul accord par commande.", d.Negotiated and "Accord déjà conclu ✓" or "Négocier −10 %", function() fire("Negotiate", "Volume") end, d.Negotiated)
  card("Relation fournisseur", (d.SupplierOrders and (d.SupplierOrders[tostring(d.Supplier)] or 0) or 0) .. " commandes chez ce fournisseur. Après 3 : remise fidélité de 15 %.", "Négocier la fidélité", function() fire("Negotiate", "Loyalty") end)
  card("Contrôle qualité", "Renonce à la remise pour gagner +0,2 de qualité sur le prochain lot.", "Choisir la qualité", function() fire("Negotiate", "Sample") end)
  for i, name in ipairs({"Petit prix • clients plus rapides", "Prix normal • conseillé", "Prix élevé • clients plus lents"}) do
   local r2 = row(42) button(r2, (d.PriceMode == i and "✓ " or "") .. name, UDim2.new(1, -12, 0, 34), UDim2.fromOffset(6, 4), function() fire("Price", i) end)
  end
  local refund = math.floor(d.Stock * C.Products[d.Product].Cost * 0.5)
  card("Vider les rayons", "Retire tous tes produits et rend seulement la moitié de leur prix de base. Ce n'est pas une vente.", liquidation and ("Confirmer : retirer " .. d.Stock .. " produits pour " .. refund .. " $") or "Voir le remboursement", function()
   if d.Stock < 1 then notice("Tes rayons sont déjà vides.") return end
   if liquidation and liquidation.Stock == d.Stock and liquidation.Product == d.Product then
    liquidation = nil fire("Liquidate")
   else
    liquidation = {Stock = d.Stock, Product = d.Product} render()
   end
  end)
  end
 elseif currentTab == "Entreprise" then
  liveLabels.progress = textRow("", 75)
  local nextLevel = C.Levels[d.Level + 1]
  if nextLevel then card("Passer à " .. nextLevel.Name, nextLevel.Cost .. " $ • " .. nextLevel.Sales .. " ventes requises • +1 rayon, stock " .. C.StockCapacity(d.Level + 1), "Agrandir mon entreprise", function() fire("Upgrade") end) end
  textRow("Tes employés travaillent dès leur recrutement. Pas de salaire à payer ensuite. Chaque employé a 3 niveaux ; les améliorations sont payantes.", 70)
  for i, role in ipairs(latest.StaffRoles or {}) do
   local rank = d.Staff and d.Staff[role.Key] or 0
   local effects = {"Encaisse les clients locaux ; accélère aux niveaux 2 et 3.", "Va chercher et porte les colis. Départ après 3 / 2 / 1 secondes ; marche plus vite à chaque niveau. Stock crédité au retour.", "Achète automatiquement 10 produits quand il en reste 3 / 4 / 5. Utilise l’argent de ta boutique.", "Recrute et améliore automatiquement les autres employés. Garde l’argent pour deux lots de produits."}
   card(role.Name .. " • niveau " .. rank .. "/3", "Entreprise " .. role.Level .. " • " .. effects[i], rank == 3 and "Niveau maximum" or ((rank == 0 and "Recruter : " or "Former : ") .. role.Cost * (rank + 1) .. " $"), function() fire("Hire", i) end, rank > 0)
  end
  if d.Staff and d.Staff.Buyer > 0 then
   card("Responsable commandes", "Il travaille automatiquement avec ton produit et ton fournisseur choisis. Il attend si tu n'as pas assez d'argent.", d.AutoOrder and "Mettre les commandes en pause" or "Reprendre les commandes", function() fire("AutoOrder") end, d.AutoOrder)
  end
  if d.Staff and d.Staff.Manager > 0 then
   card("Gérant", "Il gère ton équipe automatiquement et garde de quoi acheter deux lots. Les bâtiments et les objets personnels restent ton choix.", d.ManagerEnabled and "Mettre le gérant en pause" or "Reprendre la gestion", function() fire("Manager") end, d.ManagerEnabled)
  end
  card("Rivalité de livraison • test Studio", "Vol entre volontaires niveau 2+. Colis protégé 20 s ; assurance de 50 % en cas de perte. Désactivé sur les serveurs publiés.", d.Rivalry and "Désactiver la rivalité" or "Participer à la rivalité", function() fire("Rivalry") end, d.Rivalry)
  card("Campagne de quartier", "100 $ • visibilité accrue pendant 120 s pour les clients disputés. Aucun revenu garanti.", "Lancer la campagne", function() fire("Marketing") end)
  textRow("Couleurs de ta boutique • gratuit", 44)
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
  card("Cadeau du jour", "Prochain cadeau : " .. p.GiftDay .. " / 7. Tu ne perds rien si tu ne joues pas tous les jours.", p.GiftAvailable and "Recevoir mon cadeau" or "Cadeau reçu aujourd'hui ✓", function() fire("DailyGift") end)
  textRow("Tes objectifs • récompenses uniques", 42)
  for _, m in ipairs(p.Missions) do
   card(m.Name, m.Progress .. " / " .. m.Target .. " • récompense " .. m.Reward .. " $", m.Claimed and "Reçu ✓" or "Recevoir la récompense", function() fire("Mission", m.Id) end, m.Claimed)
  end
  textRow("Missions du jour • progression sauvegardée", 42)
  for _, m in ipairs(p.Daily) do
   card(m.Name, m.Progress .. " / " .. m.Target .. " • récompense " .. m.Reward .. " $", m.Claimed and "Reçu ✓" or "Recevoir la récompense", function() fire("DailyMission", m.Id) end, m.Claimed)
  end
  textRow("Hors ligne : avec un caissier recruté, le stock existant peut se vendre à moitié prix, une unité toutes les 2 minutes, sur 4 h maximum. Aucun réapprovisionnement hors ligne.", 100)
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
local destinations = {
 {Tab = "Marché", Text = "▣  BOUTIQUE", Color = Color3.fromRGB(44, 133, 105)},
 {Tab = "Entreprise", Text = "↑  ENTREPRISE", Color = blue},
 {Tab = "Lifestyle", Text = "◆  GARAGE", Color = Color3.fromRGB(142, 94, 205)},
 {Tab = "Objectifs", Text = "★  MISSIONS", Color = Color3.fromRGB(178, 119, 36)},
}
local function showTab(name)
 liquidation = nil currentTab = name scroll.CanvasPosition = Vector2.zero setPanel(true) render()
end
for i, destination in ipairs(destinations) do
 local tab = button(tabs, destination.Tab == "Lifestyle" and "Garage" or destination.Tab, UDim2.new(1/4, -5, 1, 0), UDim2.new((i-1)/4, 0, 0, 0), function() showTab(destination.Tab) end)
 tab.TextScaled = true local limit = Instance.new("UITextSizeConstraint") limit.MinTextSize, limit.MaxTextSize, limit.Parent = 10, 14, tab
 tabButtons[destination.Tab] = tab
 table.insert(navigation, button(nav, destination.Text, UDim2.new(), UDim2.new(), function() showTab(destination.Tab) end, destination.Color))
end
table.insert(navigation, button(nav, "⌂  MA BOUTIQUE", UDim2.new(), UDim2.new(), function() fire("Home") end, Color3.fromRGB(55, 71, 97)))
resize()
state.OnClientEvent:Connect(function(snapshot)
 local previous = latest latest = snapshot
 local d = snapshot.Data
 cash.Text = string.format("%d $", d.Cash)
 level.Text = C.Levels[d.Level].Name
 stock.Text = string.format("%d / %d", d.Stock, C.StockCapacity(d.Level))
 objectiveText.Text = Guide.Text(snapshot)
 drop.Visible = snapshot.Carrying == true and not panel.Visible
 local changed = not previous
 if liquidation and (liquidation.Stock ~= d.Stock or liquidation.Product ~= d.Product) then liquidation = nil changed = true end
 if previous then
  for _, key in ipairs({"Product", "Supplier", "PriceMode", "Level", "Color", "Negotiated", "ActiveVehicle", "AutoOrder", "DailyClaim", "ManagerEnabled", "Rivalry"}) do if previous.Data[key] ~= d[key] then changed = true end end
  for key, rank in pairs(d.Staff or {}) do if not previous.Data.Staff or previous.Data.Staff[key] ~= rank then changed = true end end
  if currentTab == "Objectifs" and (previous.Data.Sales ~= d.Sales or snapshot.Message or previous.Data.Daily.Day ~= d.Daily.Day) then changed = true end
  for key, value in pairs(d.Vehicles) do if previous.Data.Vehicles[key] ~= value then changed = true end end
  for key, value in pairs(d.Luxuries) do if previous.Data.Luxuries[key] ~= value then changed = true end end
 end
 if changed and panel.Visible then render() end
 if liveLabels.guide then
  liveLabels.guide.Text = Guide.Text(snapshot)
 end
 if liveLabels.marketInfo then liveLabels.marketInfo.Text = "Tendance : " .. C.Products[snapshot.Trend].Name .. " • " .. snapshot.TrendSeconds .. " s\nFile : " .. (snapshot.QueueCount or 0) .. "/3 • " .. snapshot.Saving end
 if liveLabels.order then liveLabels.order.Text = d.Parcel and "Colis devant la porte • à réceptionner" or d.Order and (d.Order.Remaining > 0 and ("Expédition dans " .. d.Order.Remaining .. " s…") or "Camionnette en approche / déchargement…") or ("Commander 10 unités • " .. math.ceil(C.Products[d.Product].Cost * 10 * C.Suppliers[d.Supplier].Factor * (d.Negotiated and (1 - (d.Discount or 0.1)) or 1)) .. " $") end
 if liveLabels.event then local e = snapshot.Event liveLabels.event.Text = e.Kind .. " • " .. C.Products[e.Product].Name .. "\nFin dans " .. math.max(0, e.Ends - os.time()) .. " s • collectif " .. e.Units .. "/" .. e.Target .. "\nTouristes : +20 % ; tendance surprise : +30 % sur les ventes locales concernées." end
 if liveLabels.reputation then liveLabels.reputation.Text = "Réputation : " .. snapshot.Progression.Reputation .. "/100 • clients disputés gagnés : " .. d.Disputed .. "\nPublicité restante : " .. snapshot.Progression.Marketing .. " s. Les clients privilégient tour à tour qualité, tendance ou prix." end
 if liveLabels.board then
  local lines = {"Part des clients disputés (joueurs présents, session) : " .. snapshot.MarketShare .. "%"}
  for i, entry in ipairs(snapshot.Board) do table.insert(lines, i .. ". " .. entry.Name .. " • " .. entry.Wins .. " clients • " .. C.Levels[entry.Level].Name) end
  liveLabels.board.Text = table.concat(lines, "\n")
 end
 if liveLabels.progress then liveLabels.progress.Text = "Entreprise : " .. C.Levels[d.Level].Name .. "\n" .. d.Sales ..  " ventes • argent gagné au total " .. d.Revenue .. " $\nLes achats personnels ne comptent pas comme investissement." end
 if snapshot.Message == "OPEN_MARKET" then showTab("Marché")
 elseif snapshot.Message then notice(snapshot.Message) end
end)
fire("Ready")
