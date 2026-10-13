local Movement = {}
Movement.Duration = 180
Movement.Multiplier = 1.5
function Movement.Init(d, now)
 if d.StarterBoostEnds == nil then
  d.StarterBoostEnds = (d.Sales or 0) == 0 and now + Movement.Duration or 0
 end
end
function Movement.Speed(carrying, ends, now)
 return (carrying and 11 or 16) * (now < (ends or 0) and Movement.Multiplier or 1)
end
function Movement.Apply(character)
 if not character or not character:GetAttribute("CEOPlayerMovement") then return end
 local hum = character:FindFirstChildOfClass("Humanoid")
 if hum and hum.Health > 0 then
  local speed = Movement.Speed(character:GetAttribute("CarryKind") ~= nil, character:GetAttribute("StarterBoostEnds"), os.time())
  if hum.WalkSpeed ~= speed then hum.WalkSpeed = speed end
 end
end
return Movement
