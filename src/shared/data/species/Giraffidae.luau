--!strict
-- Giraffidae: giraffes and okapi. Note on taxonomy (docs/data-review.md): in August 2025
-- the IUCN recognised four giraffe species; Giraffa camelopardalis is now the northern
-- giraffe. The species-level Red List entry still reflects the older single-species VU
-- assessment (2018), so VU is flagged as estimated pending the new assessment.

return {
	{
		id = "Giraffa camelopardalis",
		commonName = { id = "jerapah", en = "Northern giraffe" },
		taxonomy = {
			kingdom = "Animalia",
			phylum = "Chordata",
			class = "Mammalia",
			order = "Artiodactyla",
			family = "Giraffidae",
			genus = "Giraffa",
		},
		iucn = "VU", -- estimated: 2018 single-species assessment; new species-level status pending
		estimated = {
			iucn = true,
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
			-- Genus-level target on purpose: giraffes browse many Vachellia species.
			{ target = "Vachellia", efficiency = 1.0 },
		},
		size = 900,
		sizeRatioMax = 0,
		habitat = {
			biomes = { "savanna" },
			water = "none",
			climate = { tempC = { min = 0, max = 45 }, rainMm = { min = 200, max = 1200 } },
		},
		regions = { "AF" },
		lifespanDays = 9125, -- ~25 years
		hungerRate = 0.5,
		reproduction = { rate = 0.4, gestationDays = 455, litter = 1 }, -- one calf about every two years
		speed = 50,
		diseaseSusceptibility = 0.25,
	},
}
