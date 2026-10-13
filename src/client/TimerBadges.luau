local Info = require(game.ReplicatedStorage.BeACEO.EventInfo)
local Badges = {}
local function text(parent, size)
 local t = Instance.new("TextLabel")
 t.BackgroundTransparency, t.TextColor3, t.Font = 1, Color3.fromRGB(248, 250, 255), Enum.Font.GothamBold
 t.TextSize, t.TextWrapped, t.Parent = size, false, parent
 return t
end
function Badges.new(parent, name, color)
 local frame = Instance.new("Frame")
 frame.Name, frame.BackgroundTransparency, frame.Parent = name, 1, parent
 local caption, timer = text(frame, 11), text(frame, 15)
 local disc = Instance.new("Frame")
 disc.AnchorPoint, disc.BackgroundColor3, disc.BorderSizePixel, disc.Parent = Vector2.new(0.5, 0.5), color, 0, frame
 local corner = Instance.new("UICorner") corner.CornerRadius, corner.Parent = UDim.new(0.5, 0), disc
 local edge = Instance.new("UIStroke") edge.Color, edge.Thickness, edge.Transparency, edge.Parent = color, 5, 0.6, disc
 local scale = Instance.new("UIScale") scale.Parent = disc
 local value = text(disc, 25)
 value.Size, value.Position = UDim2.new(1, -14, 1, -14), UDim2.fromOffset(7, 7)
 value.TextColor3, value.Font, value.TextScaled = Color3.fromRGB(15, 25, 45), Enum.Font.GothamBlack, true
 local limit = Instance.new("UITextSizeConstraint")
 limit.MinTextSize, limit.MaxTextSize, limit.Parent = 10, 25, value
 local ticks = {}
 for i = 1, 24 do
  local angle = math.rad((i - 1) * 15)
  local tick = Instance.new("Frame")
  tick.AnchorPoint, tick.Size = Vector2.new(0.5, 0.5), UDim2.fromOffset(2, 5)
  tick.Position, tick.Rotation = UDim2.fromScale(0.5 + math.sin(angle) * 0.43, 0.5 - math.cos(angle) * 0.43), (i - 1) * 15
  tick.BackgroundColor3, tick.BorderSizePixel, tick.Parent = Color3.new(1, 1, 1), 0, disc
  ticks[i] = tick
 end
 return setmetatable({Frame = frame, Caption = caption, Timer = timer, Disc = disc, Value = value, Edge = edge, Scale = scale, Ticks = ticks}, {__index = Badges})
end
function Badges:Layout(slot, compact)
 local diameter = compact and 46 or 66
 self.Frame.Size, self.Frame.Position = UDim2.new(1/3, 0, 0, compact and 86 or 108), UDim2.new((slot - 1)/3, 0, 0, 0)
 self.Caption.Size, self.Caption.Position = UDim2.new(1, 0, 0, 16), UDim2.fromOffset(0, 0)
 self.Disc.Size, self.Disc.Position = UDim2.fromOffset(diameter, diameter), UDim2.new(0.5, 0, 0, 20 + diameter/2)
 self.Timer.Size, self.Timer.Position = UDim2.new(1, 0, 0, 20), UDim2.fromOffset(0, diameter + 23)
 self.Value.TextSize = compact and 17 or 24
 self.Timer.TextSize = compact and 12 or 15
 self.Caption.TextSize = compact and 10 or 11
end
function Badges:Update(caption, value, remaining, duration, color)
 self.Caption.Text, self.Value.Text, self.Timer.Text = caption, value, Info.Timer(remaining)
 if color then self.Disc.BackgroundColor3, self.Edge.Color = color, color end
 local fraction = math.clamp(remaining / math.max(1, duration), 0, 1)
 for i, tick in ipairs(self.Ticks) do tick.BackgroundTransparency = i <= math.ceil(fraction * #self.Ticks) and 0.1 or 0.8 end
 -- Gentle two-second pulse near the real deadline, never a flashing or fabricated timer.
 local pulse = remaining > 0 and remaining <= 15 and (0.5 + 0.5 * math.sin(os.clock() * math.pi)) or 0
 self.Scale.Scale, self.Edge.Transparency = 1 + pulse * 0.035, 0.6 - pulse * 0.2
end
return Badges
