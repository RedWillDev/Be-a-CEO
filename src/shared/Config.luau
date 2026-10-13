-- All prices use fictional company cash, never Robux.
local C = {}
C.Products = {
 {Name = "Sneakers", Cost = 18, Price = 40, Color = Color3.fromRGB(255, 154, 96)},
 {Name = "Casques audio", Cost = 25, Price = 55, Color = Color3.fromRGB(120, 147, 255)},
 {Name = "Jouets", Cost = 12, Price = 29, Color = Color3.fromRGB(103, 220, 179)},
}
C.Suppliers = {
 {Name = "Express Local", Factor = 1, Quality = 1, Delay = 7, Detail = "Fiable • livraison rapide"},
 {Name = "Factory Direct", Factor = 0.75, Quality = 0.85, Delay = 15, Detail = "Économique • marge élevée"},
 {Name = "Signature Atelier", Factor = 1.3, Quality = 1.5, Delay = 11, Detail = "Premium • meilleure réputation"},
}
C.Levels = {
 {Name = "Garage", Cost = 0, Sales = 0},
 {Name = "Boutique", Cost = 600, Sales = 10},
 {Name = "Immeuble", Cost = 1800, Sales = 35},
 {Name = "Siège", Cost = 4500, Sales = 80},
 {Name = "Tour", Cost = 10000, Sales = 160},
}
C.Vehicles = {
 {Name = "City One", Cost = 300, Speed = 30, Color = Color3.fromRGB(113, 196, 168)},
 {Name = "Urban GT", Cost = 950, Speed = 40, Color = Color3.fromRGB(240, 189, 85)},
 {Name = "Executive", Cost = 2600, Speed = 49, Color = Color3.fromRGB(104, 151, 226)},
 {Name = "Grand Touring", Cost = 6500, Speed = 58, Color = Color3.fromRGB(189, 135, 236)},
 {Name = "Apex Supercar", Cost = 14000, Speed = 68, Color = Color3.fromRGB(248, 106, 87)},
}
C.Luxuries = {
 {Name = "Montre de créateur", Cost = 250, Level = 1},
 {Name = "Salon privé", Cost = 1200, Level = 2},
 {Name = "Sculpture signature", Cost = 3500, Level = 3},
}
C.Palette = {Color3.fromRGB(77, 209, 170), Color3.fromRGB(248, 158, 101), Color3.fromRGB(125, 155, 249), Color3.fromRGB(220, 142, 234)}
function C.StockCapacity(level)
 return (math.clamp(level or 1, 1, #C.Levels) + 1) * 25
end
return C
