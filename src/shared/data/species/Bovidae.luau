--!strict
-- Bovidae: antelopes and wildebeest. Three savanna species so founder resolution can pick
-- different members of the same family.

return {
	{
		id = "Connochaetes taurinus",
		commonName = { id = "wildebeest biru", en = "Blue wildebeest" },
		taxonomy = {
			kingdom = "Animalia",
			phylum = "Chordata",
			class = "Mammalia",
			order = "Artiodactyla",
			family = "Bovidae",
			genus = "Connochaetes",
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
			{ target = "Themeda triandra", efficiency = 0.95 },
			{ target = "Vachellia tortilis", efficiency = 0.05 },
		},
		size = 220,
		sizeRatioMax = 0,
		habitat = {
			biomes = { "savanna" },
			water = "none",
			climate = { tempC = { min = 0, max = 45 }, rainMm = { min = 150, max = 1200 } },
		},
		regions = { "AF" },
		lifespanDays = 7000, -- ~19 years
		hungerRate = 0.8,
		reproduction = { rate = 1.0, gestationDays = 255, litter = 1 }, -- one calf per year
		speed = 60,
		diseaseSusceptibility = 0.3,
	},
	{
		id = "Aepyceros melampus",
		commonName = { id = "impala", en = "Impala" },
		taxonomy = {
			kingdom = "Animalia",
			phylum = "Chordata",
			class = "Mammalia",
			order = "Artiodactyla",
			family = "Bovidae",
			genus = "Aepyceros",
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
			{ target = "Themeda triandra", efficiency = 0.5 },
			{ target = "Vachellia tortilis", efficiency = 0.5 },
		},
		size = 45,
		sizeRatioMax = 0,
		habitat = {
			biomes = { "savanna" },
			water = "none",
			climate = { tempC = { min = 5, max = 45 }, rainMm = { min = 200, max = 1200 } },
		},
		regions = { "AF" },
		lifespanDays = 4700, -- ~13 years
		hungerRate = 1.0,
		reproduction = { rate = 1.0, gestationDays = 197, litter = 1 }, -- one lamb per year
		speed = 70,
		diseaseSusceptibility = 0.35,
	},
	{
		id = "Eudorcas thomsonii",
		commonName = { id = "gazel Thomson", en = "Thomson's gazelle" },
		taxonomy = {
			kingdom = "Animalia",
			phylum = "Chordata",
			class = "Mammalia",
			order = "Artiodactyla",
			family = "Bovidae",
			genus = "Eudorcas",
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
			{ target = "Themeda triandra", efficiency = 0.7 },
			{ target = "Vachellia tortilis", efficiency = 0.3 },
		},
		size = 22,
		sizeRatioMax = 0,
		habitat = {
			biomes = { "savanna" },
			water = "none",
			climate = { tempC = { min = 5, max = 45 }, rainMm = { min = 250, max = 1000 } },
		},
		regions = { "AF" },
		lifespanDays = 4000, -- ~11 years
		hungerRate = 1.1,
		reproduction = { rate = 1.0, gestationDays = 175, litter = 1 }, -- one fawn per year
		speed = 70,
		diseaseSusceptibility = 0.4,
	},
}
