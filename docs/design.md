# Design: Ecosystem Terrarium (Complex Mode)

> **RECONSTRUCTED DOCUMENT.** The original design doc was not in the repo. This file was
> rebuilt on 2026-10-11 (segment 2) from `AGENTS.md`, `docs/architecture.md`, and
> `docs/prompts/prototype0-prompts.md`. Every rule marked **[Locked]** in those sources is
> carried over verbatim in meaning. Everything else is marked **[Default]** (sensible
> proposal, change freely) or **[TBD]** (must be measured/decided). **The user must review
> this document** — it is the gameplay source of truth, and architecture.md defers to it.

Status labels: **[Locked]** decided, change only with approval. **[Default]** working
default, tunable. **[TBD]** open, must be measured or decided.

Out of scope for Prototype 0: money, upgrades, index, leaderboards, speciation, disasters,
invasive species, multiple zones, trade, sabotage, persistence, quizzes. The question
Prototype 0 answers: **is balancing the ecosystem fun?**

## 1. Vision

A tycoon-style ecosystem simulator. Each player owns a terrarium, picks plant and animal
families, runs a simulation, and watches the food web play out. Complex mode is
scientifically accurate and never pay-to-win: the joy is understanding a living system well
enough to keep it alive, and the report teaches you why it died. **[Locked]**

## 2. Core loop and fun pillars

1. Set up: pick a starter pack, place families (species resolved by seed), press Simulate.
2. Observe: populations, feeding, hunts, seasons, at 1x/10x/50x.
3. Collapse (or survive): a report explains the causal chain.
4. Learn and retry with a different setup.

Fun pillars: **legible cause and effect** ("zebra fell after drought, lions starved"),
**long-horizon care** (small early choices matter seasons later), **diversity as
achievement** (the index rewards keeping rare species alive). **[Locked]**

## 3. Runs, sessions, and speed

- One run per player plot; many sessions per server. **[Locked]**
- Speeds: 1x, 10x, 50x only. 1 real second at 1x = 1 in-game hour. Speed changes only how
  many steps run per real second, never the results. **[Locked]**
- Switching speed mid-run is allowed. **[Default]**
- Manual stop is always allowed and still produces a report. **[Locked]**
- Hard caps: 24 real hours per run; ranked runs also cap at 100 in-game years. **[Default]**
- Ranked runs: 10x or 50x only, one best run counts, entry fee paid in in-game money. 1x
  runs never reach leaderboards. **[Locked]**
- Scheduler per session: steps accrue from `dt * speed` with fractional carry; per-session
  time budget 2 ms, global 8 ms [TBD]; a slow session runs slower in real time and results
  never change. **[Default]**

## 4. World, zones, terrain, and seasons

- A terrarium has up to **4 zones**. Prototype 0 uses one savanna zone, but all structures
  stay zone-indexed. **[Locked]**
- Each zone is a grid of cells. Terrain types: `open`, `tree`, `rock`, `water`. Mix ratios
  come from biome data. **[Default]**
- Per cell: light, water availability, nutrient pool, plant biomass, plant capacity.
  **[Locked]** (capacity model)
- Season clock: 1 season = 90 in-game days, 1 day = 24 steps, a year = 4 seasons (360
  days). Savanna year: early wet, late wet, early dry, late dry. **[Default]** (the 90-day
  season is [Locked]; the 4-season year shape is [Default])
- Light and water vary by season and terrain; there is no day/night light cycle in
  Prototype 0. **[Default]**
- Water cells: only in the terrain mix above; aquatic movement is a later-phase question.
  **[TBD]**

## 5. Simulation rules

One `Sim.step(world, commands)` call advances exactly 1 in-game hour through the fixed
pipeline in architecture.md section 4.2. Determinism: every system draws from an RNG stream
derived from `(seed, systemId, step)`; external input is only a command stamped with a
step. **[Locked]**

### 5.1 Run lifecycle

1. Validate setup (pack, families, ≤10 starting individuals per species, placement fits
   biome and region). **[Locked]**
2. Resolve founders: each placed family gets species chosen by seed among that family's
   species compatible with biome, region, and terrain. Placing the same family twice rolls
   founders independently. **[Locked]**
3. Spawn starting individuals (≤10 per species), then run the step loop until collapse,
   manual stop, or a hard cap.

### 5.2 Environment and plants

- Plant capacity per cell derives from light, water, nutrients, and terrain. Growth moves
  biomass toward capacity; consumption (grazing) removes it. **[Default]**
- Plants never go fully extinct: a seed bank keeps a floor. "Near extinction" = below 10%
  of zone capacity. **[Locked]**
- When a zone has no living decomposer (fungus), nutrients from carcasses stop returning to
  soil and plant capacity slowly decays. **[Locked]**

### 5.3 Hunger and feeding

- Every animal gains hunger each day proportional to its `hungerRate` (fraction of maximum
  hunger per in-game day). Hunger 1 = starving; starvation kills. **[Default]**
- Herbivores reduce plant biomass in their current cell (grazers prefer `open` cells,
  browsers `tree` cells). Omnivores feed like herbivores and also eat carcasses. Scavengers
  eat only carcasses. **[Default]**
- A species' diet lists targets (species id, genus id, or the reserved target `carcass`)
  with an `efficiency` weight in [0, 1]. Weights are preference/conversion weights and sum
  to about 1 per species. **[Default]**
- Overgrazing (biomass far below capacity) slows regrowth the next season. **[TBD]**

### 5.4 Predation and scavenging

- A predator may only kill prey whose mass is at most `sizeRatioMax ×` its own mass.
  **[Locked]**
- Exception flags live in species data: `packHunt` raises the effective ratio (multiplier
  [TBD], start 1.5x) and kill chance for pack hunters (lions, wild dogs, spotted hyenas).
  **[Locked]** (exceptions exist in data) / **[TBD]** (numbers)
- Kill chance per encounter weighs predator hunger, speed gap, and prey awareness [TBD,
  start 30%]. Failed hunts cost the predator hunger. **[Default]**
- Prey roles are limited to herbivore and omnivore. Intra-guild killing is out of scope for
  Prototype 0. **[Default]**
- Every death produces a carcass with the dead entity's mass. Scavengers and omnivores with
  a `carcass` diet target consume carcasses. Predators with a `carcass` target may
  scavenge. **[Default]**

### 5.5 Reproduction

- Requires: a fertile mate of the same species within perception, good condition (hunger
  below a threshold [TBD, start 0.5]), and enough food in the zone. **[Default]**
- Species data sets `rate` (expected events per fertile adult per year under good
  conditions), `gestationDays`, and `litter`. Apex predators reproduce very slowly.
  **[Locked]**
- A per-zone carrying capacity limits total population [TBD formula]. **[Default]**

### 5.6 Disease

- Daily infection chance rises with zone density and poor condition, scaled by the species'
  `diseaseSusceptibility`. Disease drains health and can kill; it can spread between
  individuals of the same species. No strains, no cross-species spillover in Prototype 0.
  **[Default]**

### 5.7 Competition

- Niche overlap = shared diet targets plus shared terrain use. Competition never kills
  directly: it shows up as extra starvation pressure and failed breeding. **[Locked]**

## 6. Money and economy

- The sim exposes counters per step (effective populations, diversity inputs, native ratio,
  disaster level); `EconomyService` converts them to income using constants from
  `shared/data/economy` — never hardcoded. **[Default]**
- Complex mode: Robux can buy cosmetics and decorations only. Robux never touches sim
  results, income, or leaderboards. Sabotage uses in-game money only. **[Locked]**
- Offline exhibit income is capped at 8 hours. **[Locked]**

## 7. Species, families, founders, and the index

- The family is the ownership and placement unit; species inside it are resolved by seed
  (section 5.1). **[Locked]**
- Species ids are binomials (`Genus species`); taxonomy is real from kingdom to genus.
  Diet targets resolve to a species id, a genus id present in the database, or the reserved
  `carcass`. Values that are guesses or gameplay approximations must be flagged in the
  species' `estimated` map and reviewed in `docs/data-review.md`. **[Locked]**
- Index: a species enters the player's index after surviving a rarity-dependent number of
  seasons: LC 1, NT 2, VU 4, EN 8, CR 12. **[Default]**
- Speciation (Phase 2) rolls new species from present families; the species schema reserves
  an optional `speciation` field. **[Default]**

## 8. Social systems (Phase 1+)

- Trade: crafting seeds (bibit) from index entries, cooldowns, same-tier checks, daily
  limits. **[Default]**
- Sabotage: opt-in target list, priced by the saboteur's in-game wealth, one sabotage per
  saboteur per run, protection window after a run starts, victim compensation. A sabotage
  becomes a command with a target step, so affected runs stay reproducible. **[Locked]**
- Exhibits: exhibit slots, ratings (one per player per day, minimum progress to rate).
  **[Default]**

## 9. Collapse, end conditions, and scoring

- Animal collapse: remaining animals all belong to one feeding guild, or 2 or fewer animal
  species remain. Plant collapse: plant biomass below 10% of zone capacity. **[Locked]**
- Grace period: 1 season (90 in-game days). If the condition clears, the timer resets.
  **[Locked]**
- A zone that loses nearly all inhabitants becomes a dead zone; the run continues until the
  global condition holds. **[Default]**
- Score time is recorded at the moment collapse STARTS, not when the run stops. **[Locked]**

## 10. The final report

- Summary: duration (in-game), money earned, diversity, peak species count.
- Population timelines per species; cause-of-death breakdown per species.
- Causal collapse chain: trace the largest declines backward through feeding relations.
- Notable events: hunts, births, migrations, diseases, local extinctions.
- Per-year replay of snapshots at low cost. **[Default]**

## 11. Leaderboards

- Separate boards: per biome and terrarium tier, ranked run, weekly seed, sabotaged runs,
  and metric boards (duration, peak diversity, money). One best run counts. 10x and 50x
  share boards. Weekly seed boards give every player the same seed and starter pack.
  **[Locked]** (rules) / **[Default]** (implementation)

## 12. UI and player experience

- Setup screen: pack, families with counts (≤10 per species), auto-placement, Simulate.
- Run HUD: speed buttons, in-game date (year, season, day), species alive, live population
  charts fed by `Stats` messages only.
- Index tree with taxonomy; report viewer after a run.
- Level of detail by speed: 1x full animation, 10x simplified, 50x minimal markers.
  Rendered entities capped (start 150 [TBD]); the rest render as aggregate markers.
  **[Default]**
- Every entity renders as a plain cube Part sized by species `size` and colored by role,
  created through one factory (`EntityView.create`); real models replace cubes later.
  **[Locked]** (no Humanoids, no models/meshes unless asked)

## 13. Data conventions and scientific accuracy

- Taxonomy (kingdom → genus), diet, habitat, region, and IUCN status come from real
  sources. Do not invent species relationships for convenience. **[Locked]**
- Species ids: `"Genus species"` binomial, matching `taxonomy.genus`. One file per family
  under `src/shared/data/species/`.
- IUCN codes: `LC | NT | VU | EN | CR | DD`. When no global IUCN assessment exists or the
  taxonomy is contested, use the closest honest code, flag `iucn` in `estimated`, and list
  it in `docs/data-review.md`.
- `estimated` maps dotted field paths to `true` for every guess or gameplay approximation.
  The validator requires flags for: `size`, `hungerRate`, `lifespanDays`,
  `reproduction.rate`, `diseaseSusceptibility`, plus `speed` (when > 0), `sizeRatioMax`
  (when > 0), `packHunt` (when true), and `diet` (when non-empty). Real field values
  (gestation, litter, clutch sizes) stay unflagged.
- Units and semantics:

  | Field | Unit / meaning |
  |---|---|
  | `size` | representative adult body mass, kg (plants/fungi: mature mass) |
  | `speed` | sustained travel speed, km/h; 0 for immobile roles |
  | `hungerRate` | fraction of maximum hunger gained per in-game day; 0 for plants/fungi |
  | `lifespanDays` | typical wild lifespan in days |
  | `reproduction.rate` | expected breeding events per fertile adult per year, good conditions |
  | `reproduction.gestationDays` | gestation (birds: incubation; plants/fungi: time to seed/spore set) |
  | `reproduction.litter` | typical offspring (or seeds) per event |
  | `sizeRatioMax` | max prey mass / own mass for a solo kill; 0 = never kills |
  | `packHunt` | true if the species hunts in groups (data exception to the size rule) |
  | `diseaseSusceptibility` | relative susceptibility in [0, 1] (gameplay) |
  | `diet[].efficiency` | preference/conversion weight in [0, 1]; weights sum to about 1 |

- Reserved diet target `carcass` is allowed only for roles `carnivore`, `omnivore`, and
  `scavenger`. Genus-level targets (for example `"Vachellia"`) are allowed when the animal
  genuinely eats several species of that genus. **[Default]**
- `regions` uses continent codes (this pack: `AF`). `habitat.water`: `none`, `semi`, `full`.
  **[Default]**
- Plants never go fully extinct (seed bank floor). Bacteria and archaea are not simulated.
  **[Locked]**
- All tunable constants live in `src/shared/data/`, never hardcoded in logic. **[Locked]**
- Any data change must pass `lune run tools/validate_data`; reviewable estimates live in
  `docs/data-review.md`. **[Locked]**
