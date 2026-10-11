--!strict
-- Poaceae: grasses. Themeda triandra is the keystone savanna grazer grass.

return {
	{
		id = "Themeda triandra",
		commonName = { id = "rumput kanguru", en = "Kangaroo grass" },
		taxonomy = {
			kingdom = "Plantae",
			phylum = "Tracheophyta",
			class = "Liliopsida",
			order = "Poales",
			family = "Poaceae",
			genus = "Themeda",
		},
		iucn = "LC", -- estimated: no confirmed global IUCN assessment found; LC per SANBI national Red List
		estimated = {
			iucn = true,
			size = true,
			hungerRate = true,
			lifespanDays = true,
			["reproduction.rate"] = true,
			["reproduction.gestationDays"] = true,
			["reproduction.litter"] = true,
			diseaseSusceptibility = true,
			["habitat.climate"] = true,
		},
		role = "plant",
		diet = {},
		size = 3, -- kg of standing biomass per mature tussock
		sizeRatioMax = 0,
		habitat = {
			biomes = { "savanna" },
			water = "none",
			climate = { tempC = { min = 5, max = 45 }, rainMm = { min = 250, max = 2000 } },
		},
		regions = { "AF" },
		lifespanDays = 1825, -- perennial tussock, ~5 years
		hungerRate = 0,
		reproduction = { rate = 2.0, gestationDays = 90, litter = 100 }, -- seed set per wet season
		speed = 0,
		diseaseSusceptibility = 0.1,
	},
}
