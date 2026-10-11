--!strict
-- Fabaceae: acacias. Vachellia tortilis, the umbrella thorn, is the classic savanna browse.

return {
	{
		id = "Vachellia tortilis",
		commonName = { id = "pohon payung", en = "Umbrella thorn acacia" },
		taxonomy = {
			kingdom = "Plantae",
			phylum = "Tracheophyta",
			class = "Magnoliopsida",
			order = "Fabales",
			family = "Fabaceae",
			genus = "Vachellia",
		},
		iucn = "LC", -- confirmed: IUCN 2020-2 assessment, widespread across Africa
		estimated = {
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
		size = 2000, -- kg per mature tree
		sizeRatioMax = 0,
		habitat = {
			biomes = { "savanna" },
			water = "none",
			climate = { tempC = { min = 5, max = 48 }, rainMm = { min = 40, max = 1200 } },
		},
		regions = { "AF" },
		lifespanDays = 36500, -- ~100 years
		hungerRate = 0,
		reproduction = { rate = 0.2, gestationDays = 180, litter = 500 }, -- pod crops in good years
		speed = 0,
		diseaseSusceptibility = 0.05,
	},
}
