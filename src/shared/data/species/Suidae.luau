--!strict
-- Suidae: pigs. Phacochoerus africanus, the common warthog, grazes and digs for roots.

return {
	{
		id = "Phacochoerus africanus",
		commonName = { id = "babi hutan", en = "Common warthog" },
		taxonomy = {
			kingdom = "Animalia",
			phylum = "Chordata",
			class = "Mammalia",
			order = "Artiodactyla",
			family = "Suidae",
			genus = "Phacochoerus",
		},
		iucn = "LC",
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
			{ target = "Themeda triandra", efficiency = 0.8 },
			{ target = "Vachellia tortilis", efficiency = 0.2 },
		},
		size = 60,
		sizeRatioMax = 0,
		habitat = {
			biomes = { "savanna" },
			water = "none",
			climate = { tempC = { min = 5, max = 45 }, rainMm = { min = 200, max = 1200 } },
		},
		regions = { "AF" },
		lifespanDays = 5475, -- ~15 years
		hungerRate = 1.0,
		reproduction = { rate = 1.0, gestationDays = 172, litter = 3 }, -- one litter of 2-4 per year
		speed = 45,
		diseaseSusceptibility = 0.35,
	},
}
