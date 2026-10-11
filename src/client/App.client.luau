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
button(gui, "Mon garage", UDim2.fromOffset(120, 42), UDim2.new(1, -132, 0, 104), function() fire("Home") end)
local panel = Instance.new("Frame") panel.Name = "Management" panel.Size, panel.Position = UDim2.new(0, 560, 0.68, 0), UDim2.new(0, 12, 0, 158) panel.BackgroundColor3 = Color3.fromRGB(24, 35, 47) panel.Parent = gui round(panel)
local constraint = Instance.new("UISizeConstraint") constraint.MaxSize, constraint.MinSize, constraint.Parent = Vector2.new(560, 610), Vector2.new(280, 200), panel
local function resize()
 local v = workspace.CurrentCamera.ViewportSize
 panel.Size = UDim2.new(0, math.min(560, v.X - 24), 0, math.max(200, math.min(610, v.Y - 220)))
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
 title.Text = currentTab == "Marché" and "MARKETBRIDGE" or currentTab == "Entreprise" and "TA MARQUE, TA VILLE" or "LA VIE DE CEO"
 if currentTab == "Marché" then
  liveLabels.guide = textRow("", 65)
  local quickOrder = row(52)
  liveLabels.order = button(quickOrder, "Commander", UDim2.new(1, -20, 0, 36), UDim2.fromOffset(10, 8), function() fire("Order") end, Color3.fromRGB(31, 112, 94))
  for i, product in ipairs(C.Products) do card(product.Name, "Base : " .. product.Cost .. " $ / unité • vente conseillée : " .. product.Price .. " $", d.Product == i and "Produit en vitrine ✓" or "Choisir ce produit", function() fire("Product", i) end, d.Product == i) end
  textRow("Fournisseurs • compare coût, qualité et délai", 40)
  for i, supplier in ipairs(C.Suppliers) do card(supplier.Name, supplier.Detail .. " • " .. supplier.Delay .. " s • qualité " .. supplier.Quality, d.Supplier == i and "Fournisseur sélectionné ✓" or "Choisir", function() fire("Supplier", i) end, d.Supplier == i) end
  card("Négocier le prochain lot", "Propose un engagement sur 10 unités pour obtenir 10 % de remise.", d.Negotiated and "Remise obtenue ✓" or "Proposer un achat en volume", function() fire("Negotiate", "Volume") end, d.Negotiated)
  local r = row(52)
  button(r, "Commander le lot sélectionné", UDim2.new(1, -20, 0, 36), UDim2.fromOffset(10, 8), function() fire("Order") end, Color3.fromRGB(31, 112, 94))
  textRow("Les clients achètent automatiquement le stock. Le prix économique vend plus vite ; le premium vend plus lentement. La qualité et la tendance attirent les clients disputés.", 78)
  for i, name in ipairs({"Économique • ventes rapides", "Équilibré • prix conseillé", "Premium • marge élevée"}) do
   local r2 = row(42) button(r2, (d.PriceMode == i and "✓ " or "") .. name, UDim2.new(1, -12, 0, 34), UDim2.fromOffset(6, 4), function() fire("Price", i) end)
  end
 elseif currentTab == "Entreprise" then
  liveLabels.progress = textRow("", 75)
  local nextLevel = C.Levels[d.Level + 1]
  if nextLevel then card("Passer à " .. nextLevel.Name, nextLevel.Cost .. " $ • " .. nextLevel.Sales .. " ventes cumulées requises", "Agrandir mon entreprise", function() fire("Upgrade") end) end
  textRow("Identité de marque • personnalisation gratuite", 44)
  for i in ipairs(C.Palette) do local r = row(42) button(r, "Palette " .. i .. (d.Color == i and " ✓" or ""), UDim2.new(1, -12, 0, 34), UDim2.fromOffset(6, 4), function() fire("Color", i) end, C.Palette[i]) end
  textRow("Sur la place au nord : accompagne le client VIP jusqu'à ton comptoir pour une vente x3. Tu marches plus lentement et il faut du stock. Entrer dans une voiture abandonne le VIP.", 100)
  local r = row(42) button(r, "Relâcher le VIP", UDim2.new(1, -12, 0, 34), UDim2.fromOffset(6, 4), function() fire("Drop") end)
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
for i, name in ipairs({"Marché", "Entreprise", "Lifestyle"}) do button(tabs, name, UDim2.new(1/3, -5, 1, 0), UDim2.new((i-1)/3, 0, 0, 0), function() currentTab = name render() end) end
state.OnClientEvent:Connect(function(snapshot)
 local previous = latest latest = snapshot
 local d = snapshot.Data
 cash.Text = string.format("%d $  •  %s", d.Cash, C.Levels[d.Level].Name)
 summary.Text = string.format("Stock %d • %d ventes • parcelle %d\nTendance : %s (%ds) • %s", d.Stock, d.Sales, snapshot.Plot, C.Products[snapshot.Trend].Name, snapshot.TrendSeconds, snapshot.Saving)
 local changed = not previous
 if previous then
  for _, key in ipairs({"Product", "Supplier", "PriceMode", "Level", "Color", "Negotiated", "ActiveVehicle"}) do if previous.Data[key] ~= d[key] then changed = true end end
  for key, value in pairs(d.Vehicles) do if previous.Data.Vehicles[key] ~= value then changed = true end end
  for key, value in pairs(d.Luxuries) do if previous.Data.Luxuries[key] ~= value then changed = true end end
 end
 if changed then render() end
 if liveLabels.guide then liveLabels.guide.Text = d.Sales == 0 and "01 / PREMIÈRE VENTE\nChoisis un produit, négocie, commande 10 unités. Les clients arrivent dès la livraison." or "Les affaires tournent ! Réapprovisionne, adapte ton prix et suis les tendances de la ville." end
 if liveLabels.order then liveLabels.order.Text = d.Order and ("Livraison dans " .. d.Order.Remaining .. " s…") or ("Commander 10 unités • " .. math.ceil(C.Products[d.Product].Cost * 10 * C.Suppliers[d.Supplier].Factor * (d.Negotiated and 0.9 or 1)) .. " $") end
 if liveLabels.progress then liveLabels.progress.Text = "Entreprise : " .. C.Levels[d.Level].Name .. "\n" .. d.Sales .. " ventes • chiffre d'affaires " .. d.Revenue .. " $\nLes achats personnels ne comptent pas comme investissement." end
 if snapshot.Message == "OPEN_MARKET" then currentTab = "Marché" panel.Visible = true render()
 elseif snapshot.Message then notice(snapshot.Message) end
end)
fire("Ready")
