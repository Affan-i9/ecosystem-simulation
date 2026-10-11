--!strict
-- Type definitions for the data layer (design.md section 13, architecture.md 4.3).
-- Types only: no runtime values. Consumers require this module purely for type positions.
-- Units and semantics for every numeric field are documented in design.md section 13.

export type Role = "plant" | "herbivore" | "carnivore" | "omnivore" | "scavenger" | "decomposer"

export type IucnStatus = "LC" | "NT" | "VU" | "EN" | "CR" | "DD"

export type WaterUse = "none" | "semi" | "full"

export type Range = {
	min: number,
	max: number,
}

-- Climate tolerance as annual averages. Species ranges must overlap their biome's range.
export type ClimateRange = {
	tempC: Range,
	rainMm: Range,
}

export type Taxonomy = {
	kingdom: string,
	phylum: string,
	class: string,
	order: string,
	family: string,
	genus: string,
}

-- One food preference. `target` is a species id, a genus id present in the database, or
-- the reserved target "carcass" (roles carnivore, omnivore, scavenger only).
-- `efficiency` is a preference/conversion weight in [0, 1]; weights sum to about 1.
export type DietEntry = {
	target: string,
	efficiency: number,
}

export type Species = {
	-- Binomial "Genus species"; must match taxonomy.genus.
	id: string,
	commonName: { id: string, en: string },
	taxonomy: Taxonomy,
	iucn: IucnStatus,
	-- Dotted field paths -> true for every guessed or gameplay-approximated field.
	estimated: { [string]: boolean },
	role: Role,
	diet: { DietEntry },
	-- Representative adult body mass in kg.
	size: number,
	-- Max prey mass / own mass for a solo kill; 0 = never kills.
	sizeRatioMax: number,
	-- Data exception to the size rule (design.md 5.4); nil means false.
	packHunt: boolean?,
	habitat: {
		biomes: { string },
		water: WaterUse,
		climate: ClimateRange,
	},
	-- Continent codes, e.g. "AF".
	regions: { string },
	lifespanDays: number,
	-- Fraction of maximum hunger gained per in-game day; 0 for plants and fungi.
	hungerRate: number,
	reproduction: {
		-- Expected events per fertile adult per year under good conditions.
		rate: number,
		gestationDays: number,
		litter: number,
	},
	-- Sustained travel speed in km/h; 0 for immobile roles.
	speed: number,
	diseaseSusceptibility: number,
	-- Reserved for Phase 2 (speciation); omitted in Prototype 0 data.
	speciation: {
		weight: number,
		candidates: { string }?,
	}?,
}

export type Biome = {
	id: string,
	name: string,
	description: string,
	climate: ClimateRange,
	-- Terrain mix ratios over the zone grid; keys are terrain types and must sum to about 1.
	terrain: {
		open: number,
		tree: number,
		rock: number,
		water: number,
	},
}

export type StarterPack = {
	id: string,
	name: string,
	biomeId: string,
	region: string,
	-- Families the player may place in this pack, by taxonomy family name.
	families: { string },
	-- Species spawned at run start; counts respect the locked 10-per-species maximum.
	starting: {
		{ speciesId: string, count: number },
	},
}
