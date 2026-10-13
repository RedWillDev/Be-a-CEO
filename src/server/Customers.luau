-- Session-only FIFO queue; no stock or money changes happen in this module.
local Customers = {}
Customers.__index = Customers
function Customers.new(world, valid, send)
 return setmetatable({World = world, Valid = valid, Send = send, Capacity = 3}, Customers)
end
function Customers:Sync(s)
 local first = s.Customers and s.Customers[1]
 local ready = first and first.AtSlot == 1 and not first.Moving
 s.Visitor = first and first.Model or nil
 s.Waiting = ready and first.Bonus or nil
 s.WaitingKind = ready and first.Kind or nil
 s.ArrivedAt = ready and first.ReadyAt or nil
end
function Customers:Label(entry, slot)
 if not entry.Model.Parent then return end
 local label = entry.Model:FindFirstChild("CheckoutLabel", true)
 if not label then
  label = Instance.new("BillboardGui") label.Name = "CheckoutLabel"
  label.Size, label.StudsOffset, label.AlwaysOnTop = UDim2.fromOffset(190, 36), Vector3.new(0, 3, 0), true
  label.Parent = entry.Model.PrimaryPart
  local text = Instance.new("TextLabel") text.Size, text.BackgroundTransparency = UDim2.fromScale(1, 1), 1
  text.TextColor3, text.TextSize, text.Parent = Color3.fromRGB(220, 245, 235), 15, label
 end
 label.TextLabel.Text = entry.Browsing and "Choisit un produit" or entry.Moving and "Rejoint la file" or (slot == 1 and "En attente de paiement" or "File : " .. slot)
end
function Customers:Remove(player, s, entry)
 local index = table.find(s.Customers or {}, entry)
 if not index then return end
 table.remove(s.Customers, index)
 if entry.Model then
  local label = entry.Model:FindFirstChild("CheckoutLabel", true) if label then label:Destroy() end
  self.World.ReleaseCustomer(entry.Model, s.Plot)
 end
 self:Refresh(player, s)
end
function Customers:FinishMove(player, s, entry, slot, reached)
 if not table.find(s.Customers or {}, entry) then return end
 entry.Moving = false
 if not reached or not self.Valid(player) or not entry.Model.Parent or s.Data.Stock < 1 then self:Remove(player, s, entry) return end
 entry.AtSlot, entry.ReadyAt = slot, os.clock()
 self.World.FaceQueue(entry.Model, s.Plot)
 self:Refresh(player, s)
 self.Send(player)
end
function Customers:FinishBrowse(player, s, entry, reached)
 if not table.find(s.Customers or {}, entry) then return end
 if not reached or not self.Valid(player) or not entry.Model.Parent or s.Data.Stock < 1 then self:Remove(player, s, entry) return end
 local position = entry.Model.PrimaryPart.Position
 local towardShelf = self.World.Plots[s.Plot].CF:VectorToWorldSpace(Vector3.new(-1, 0, 0))
 entry.Model:PivotTo(CFrame.lookAt(position, position + towardShelf))
 task.delay(1.5, function()
  local slot = table.find(s.Customers or {}, entry)
  if not slot then return end
  if not self.Valid(player) or not entry.Model.Parent or s.Data.Stock < 1 then self:Remove(player, s, entry) return end
  entry.Browsing = false
  local cf = self.World.Plots[s.Plot].CF
  self.World.Route(entry.Model, {(cf * CFrame.new(-11, 3.5, -6)).Position, self.World.QueuePosition(s.Plot, slot)}, function(arrived)
   self:FinishMove(player, s, entry, slot, arrived)
  end)
  self:Refresh(player, s)
 end)
end
function Customers:Refresh(player, s)
 for slot, entry in ipairs(s.Customers or {}) do
  if entry.Model and entry.Model.Parent then
   if not entry.Moving and entry.AtSlot ~= slot then
    entry.Moving = true
    self.World.Route(entry.Model, {self.World.QueuePosition(s.Plot, slot)}, function(reached)
     self:FinishMove(player, s, entry, slot, reached)
    end)
   end
   self:Label(entry, slot)
  end
 end
 self:Sync(s)
end
function Customers:CanJoin(s)
 local count = #(s.Customers or {})
 return count < self.Capacity and count < s.Data.Stock
end
function Customers:Invite(player, s, bonus, kind)
 if not self:CanJoin(s) then return end
 s.Customers = s.Customers or {}
 local slot = #s.Customers + 1
 local entry = {Bonus = bonus, Kind = kind, Moving = true, Browsing = true}
 local model = self.World.Visit(s.Plot, function(_, reached) self:FinishBrowse(player, s, entry, reached) end, slot)
 if not model then return end
 entry.Model = model table.insert(s.Customers, entry)
 self:Refresh(player, s)
end
function Customers:Admit(player, s, npc, bonus, kind)
 s.Customers = s.Customers or {}
 local slot = #s.Customers + 1
 local entry = {Model = npc, Bonus = bonus, Kind = kind, Moving = true, Browsing = true}
 table.insert(s.Customers, entry)
 npc:SetAttribute("Shopping", true)
 self.World.Browse(npc, s.Plot, slot, function(reached) self:FinishBrowse(player, s, entry, reached) end)
 self:Refresh(player, s)
end
function Customers:Clear(s)
 local entries = s.Customers or {} s.Customers = {}
 self:Sync(s)
 for _, entry in ipairs(entries) do
  if entry.Model then
   local label = entry.Model:FindFirstChild("CheckoutLabel", true) if label then label:Destroy() end
   self.World.ReleaseCustomer(entry.Model, s.Plot)
  end
 end
end
function Customers:Prune(player, s)
 if s.Data.Stock < 1 then self:Clear(s) return end
 for i = #(s.Customers or {}), 1, -1 do
  local entry = s.Customers[i]
  local hum = entry.Model and entry.Model:FindFirstChildOfClass("Humanoid")
  if not entry.Model or not entry.Model.Parent or not hum or hum.Health <= 0 then self:Remove(player, s, entry) end
 end
end
function Customers:Served(player, s)
 local entry = s.Customers and s.Customers[1]
 if entry then self:Remove(player, s, entry) end
 if s.Data.Stock < 1 then self:Clear(s) end
end
return Customers
