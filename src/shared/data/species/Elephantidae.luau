--!strict
-- Elephantidae: elephants. Loxodonta africana, the African savanna elephant, is a mixed
-- feeder that shapes the landscape (pushing over trees, opening paths).

return {
	{
		id = "Loxodonta africana",
		commonName = { id = "gajah sabana", en = "African savanna elephant" },
		taxonomy = {
			kingdom = "Animalia",
			phylum = "Chordata",
			class = "Mammalia",
			order = "Proboscidea",
			family = "Elephantidae",
			genus = "Loxodonta",
		},
		iucn = "EN", -- 2021 assessment after the savanna/forest elephant split
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
			{ target = "Themeda triandra", efficiency = 0.5 },
			{ target = "Vachellia tortilis", efficiency = 0.5 },
		},
		size = 3000,
		sizeRatioMax = 0,
		habitat = {
			biomes = { "savanna" },
			water = "none",
			climate = { tempC = { min = 0, max = 45 }, rainMm = { min = 100, max = 1200 } },
		},
		regions = { "AF" },
		lifespanDays = 21900, -- ~60 years
		hungerRate = 0.3,
		reproduction = { rate = 0.22, gestationDays = 660, litter = 1 }, -- one calf every 4-5 years
		speed = 30,
		diseaseSusceptibility = 0.15,
	},
}
