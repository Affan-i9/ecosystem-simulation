--!strict
-- Equidae: horses and zebras. Equus quagga, the plains zebra, is a grazer of the savanna.

return {
	{
		id = "Equus quagga",
		commonName = { id = "zebra biasa", en = "Plains zebra" },
		taxonomy = {
			kingdom = "Animalia",
			phylum = "Chordata",
			class = "Mammalia",
			order = "Perissodactyla",
			family = "Equidae",
			genus = "Equus",
		},
		iucn = "NT",
		estimated = {
			size = true,
			speed = true,
			hungerRate = true,
			lifespanDays = true,
			["reproduction.rate"] = true,
			diseaseSusceptibility = true,
			diet = true,
			["habitat.climate"] = true,
		},
		role = "herbivore",
		diet = {
			{ target = "Themeda triandra", efficiency = 0.9 },
			{ target = "Vachellia tortilis", efficiency = 0.1 },
		},
		size = 300,
		sizeRatioMax = 0,
		habitat = {
			biomes = { "savanna" },
			water = "none",
			climate = { tempC = { min = 0, max = 45 }, rainMm = { min = 150, max = 1200 } },
		},
		regions = { "AF" },
		lifespanDays = 7300, -- ~20 years
		hungerRate = 0.8,
		reproduction = { rate = 0.5, gestationDays = 370, litter = 1 }, -- one foal about every two years
		speed = 50,
		diseaseSusceptibility = 0.3,
	},
}
