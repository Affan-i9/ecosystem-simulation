# Prototype 0: Prompt Segments for opencode

Goal of Prototype 0: one biome (savanna), one starter pack, about 15 to 20 species, a deterministic simulation with fixed steps, collapse detection, a simple report, and speeds 1x/10x/50x. The question it must answer: **is balancing the ecosystem fun?**

Out of scope for Prototype 0: money, upgrades, index, leaderboards, speciation, disasters, invasive species, multiple zones, trade, sabotage, persistence, quizzes.

## How to use these prompts

1. **One segment per opencode session.** Start a fresh session for each segment so the context stays small. Do not paste two segments into one session.
2. **Run them in order.** Each segment depends on the previous one.
3. **Review between segments.** Run `lune run tests/run`, read the agent's summary, skim the diff, and only then continue. If something is off, fix it in the same segment before moving on.
4. **Handoff file.** Every segment reads and updates `docs/progress.md`. This is the agent's memory between sessions, so keep it short and accurate.
5. **If the agent drifts**, send: "Stop. Re-read the Task and Don't sections of the prompt and continue only with the Task."
6. **If the agent asks a design question** that the docs do not answer, answer it yourself or tell it to pick the simplest option and record it under "Decisions" in `docs/progress.md`.

Segments:

| # | Segment | Output |
|---|---|---|
| 1 | Foundations | Module loading convention, seeded RNG, hash, test runner |
| 2 | Data layer | Types, savanna species data, validator |
| 3 | World and plants | World state, setup, founders, environment, plant growth |
| 4 | Animal behavior | Needs, decisions, movement, feeding, predation, death, decomposition |
| 5 | Life cycle and collapse | Reproduction, disease, competition, collapse, event log, determinism tests |
| 6 | Balance harness | Many-seed runs, tuning constants, performance benchmark |
| 7 | Server session | Scheduler, speeds, remotes, replication |
| 8 | Client and report | Rendering, setup UI, graphs, final report, Studio verification |

## Template for `docs/progress.md` (created in segment 1)

```markdown
# Progress

## Current segment
(none yet)

## Done
- (segment, date, one line)

## Decisions
- (decision, reason, segment)

## Conventions
- Module loading: (filled in segment 1)

## Open issues
- (issue, owner)

## Data review needed
- (see docs/data-review.md)
```

---

## Segment 1: Foundations

````text
Read AGENTS.md first, then docs/architecture.md sections 1, 2, 3, 3.1, 11 and 13. Do ONLY the task below.

## Context
The repo is set up with Rojo, Rokit, Lune and the Roblox Studio MCP. No game code exists yet. The simulation core in src/shared/sim must run both in Roblox and headless in Lune, and must be deterministic.

## Task
1. Pick ONE module-loading convention that works in both Roblox (via Rojo) and Lune. Check what current Roblox and Lune versions actually support (string-based requires or a thin loader shim used only by tests). Apply it to one example module and prove it works in both places. Record the choice in docs/architecture.md (replace the open question in section 13) and in docs/progress.md.
2. Implement src/shared/util/Rng.luau: a seeded PRNG using integer math only (use bit32), so outputs are identical in Lune and Roblox. API: Rng.new(seed), :nextInt(n), :nextFloat(), :chance(p), and Rng.derive(seed, ...parts) to create independent streams (for example by system id and step). Document the algorithm in a short header comment.
3. Implement src/shared/util/Hash.luau: a stable 32-bit hash (FNV-1a style) that can be fed numbers and strings in order and returns a final value. It will be used to hash the world state.
4. Create tests/run.luau: a minimal test runner (discovers files in tests/, prints pass/fail, exits non-zero on failure). Add tests for Rng (known output vectors for a fixed seed, derive independence, range checks) and Hash (known vectors, order sensitivity).
5. Prove cross-platform equality: run the same Rng vector in Studio through MCP (execute_luau in Edit or a short playtest) and confirm it matches the Lune result. Report both outputs.
6. Create docs/progress.md using EXACTLY this template, then fill in this segment. Do not ask for the template; it is here:

```markdown
# Progress

## Current segment
(none yet)

## Done
- (segment, date, one line)

## Decisions
- (decision, reason, segment)

## Conventions
- Module loading: (filled in segment 1)

## Open issues
- (issue, owner)

## Data review needed
- (see docs/data-review.md)
```

## Don't
- Do not write any simulation, species data, server, or client code.
- Do not use math.random, os.time, os.clock or tick anywhere in src/shared.
- Do not edit Rojo-managed scripts through Studio MCP tools. MCP is only for verification here.

## Definition of done
- stylua, selene and `lune run tests/run` pass.
- The Rng vector matches between Lune and Studio.
- docs/architecture.md and docs/progress.md updated.
- Reply in Indonesian: what you built, the convention you chose and why, the verification results, anything unresolved. Then STOP. Do not start the next segment.
````

---

## Segment 2: Data layer

````text
Read AGENTS.md, then docs/architecture.md sections 4.3, 4.4 and 11, docs/design.md sections 4, 5.3, 5.4, 7 and 13, and docs/progress.md. Do ONLY the task below.

## Context
Foundations (Rng, Hash, test runner, module convention) are done. Species are data-driven: adding a species must never require new logic.

## Task
1. Create Luau types in src/shared/types: Species, Biome, ClimateRange, StarterPack, DietEntry, Taxonomy. Follow the schema in architecture.md section 4.3. Adjust field names only if you have a clear reason and record it in docs/progress.md.
2. Create the savanna biome and ONE starter pack ("Savanna, Africa") under src/shared/data. The pack contains a starting plant, herbivore, and decomposer, plus the list of families the player may place in this prototype.
3. Create 15 to 20 species data entries for an African savanna, using real taxonomy (kingdom to genus, family, species), real diets, and real IUCN status. Suggested set (adjust if you know a better one):
   - Plants: Themeda triandra (Poaceae), Vachellia tortilis (Fabaceae)
   - Herbivores: Equus quagga, Connochaetes taurinus, Aepyceros melampus, Eudorcas thomsonii, Giraffa camelopardalis, Phacochoerus africanus, Loxodonta africana
   - Omnivore: Papio anubis
   - Carnivores: Panthera leo, Acinonyx jubatus, Lycaon pictus, Crocuta crocuta
   - Scavenger: Gyps africanus
   - Decomposer (fungi): Termitomyces titanicus (or a close, well-documented alternative)
   Group files by family or ordo. At least two families must contain 2 or more species, so founder resolution can be tested later.
4. Numeric values (size, speed, hunger rate, lifespan, reproduction, sizeRatioMax) are tuned for gameplay but must stay plausible. Every field that is a guess or a gameplay approximation must be listed in the species' `estimated` map.
5. Create docs/data-review.md: a table of every species with each estimated field and the reason, so the user can review them.
6. Implement tools/validate_data.luau (Lune): checks that all diet targets exist (species or genus ids), taxonomy is complete, IUCN codes are valid, every family has at least one species, every herbivore has a food source, every carnivore has prey in the pack, estimated fields are flagged, and no species is orphaned. Add tests/data tests that run the validator and include a few intentionally broken fixtures proving it catches errors.

## Don't
- Do not write simulation logic, server, or client code.
- Do not invent facts you are unsure about. Mark them estimated or leave a TODO listed in docs/data-review.md.
- Do not put species-specific behavior in code.

## Definition of done
- `lune run tools/validate_data` and `lune run tests/run` pass; stylua and selene pass.
- docs/data-review.md exists and is complete.
- docs/progress.md updated.
- Reply in Indonesian: species list, anything you were unsure about, what the user should review. Then STOP.
````

---

## Segment 3: World and plants

````text
Read AGENTS.md, then docs/architecture.md sections 4.1, 4.2 (steps 1 to 3), 4.4 and 5.2, docs/design.md sections 4 and 5, and docs/progress.md. Do ONLY the task below.

## Context
Data and validator exist. Now build the world state and the environment/plant part of the simulation. No animal behavior yet.

## Task
1. Create src/shared/sim/World.luau: the World structure from architecture.md section 4.1, with a single zone for now, but keep all structures zone-indexed so up to 4 zones fit later. Entities use struct-of-arrays with integer ids. Iteration is always in ascending id order.
2. Create src/shared/sim/Setup.luau: a Setup type (starter pack id, terrain layout, placements as family + count + optional position, auto-placement flag) and a pure validate(setup) function: max 10 starting individuals per species, family must be owned/allowed by the pack, placements must fit the biome and region, terrain must be valid. Return clear error codes.
3. Create src/shared/sim/Founders.luau: resolve a family to a founder species using a seeded Rng stream, only among species compatible with the biome, region and terrain. Placing the same family twice may produce two different founders.
4. Create the zone grid: terrain types (open, water, tree, rock), per-cell light, water availability, nutrient pool, plant biomass and capacity. Season clock: 1 season = 90 days, 1 step = 1 in-game hour.
5. Implement the environment step (season, light, water) and plant growth/regrowth with capacity limits and a seed-bank floor, so plants can approach but never reach zero. Use constants from data, not hardcoded numbers.
6. Create src/shared/sim/Sim.luau with: Sim.new(setup, seed) returning a World with entities spawned (stationary for now), Sim.step(world, commands) running only the environment and plant systems in the order from architecture.md, and Sim.hash(world) producing a stable hash of the full state.
7. Tests: same seed gives same hash after N steps; different seeds differ; plants never reach zero; setup validation rejects bad input; founders respect compatibility; entity ids are stable and ascending.

## Don't
- Do not implement hunger, movement, eating, or reproduction.
- Do not use pairs() where order can change results.
- Do not touch server or client code.

## Definition of done
- stylua, selene, validate_data and `lune run tests/run` pass.
- docs/progress.md updated; any new decision recorded.
- Reply in Indonesian with a short summary and any open question. Then STOP.
````

---

## Segment 4: Animal behavior

````text
Read AGENTS.md, then docs/architecture.md sections 4.1, 4.2 (steps 4 to 7 and 9), 4.4 and 11, docs/design.md sections 5.3 to 5.7, and docs/progress.md. Do ONLY the task below.

## Context
World, setup, founders, environment and plants work. Now add animal and fungus behavior, one system at a time. Each system gets its own Rng stream derived from (seed, systemId, step).

## Task
Implement these systems in order. After each one, add tests and commit-ready code before moving to the next.
1. Aging and metabolism: hunger rate, health, natural death at lifespan. Hunger depends on size and role.
2. Perception and decision: a per-entity state machine (idle, forage, hunt, flee, rest). Use a uniform spatial grid for neighbor queries. States depend on hunger and nearby targets, with all targets resolved from species diet data.
3. Movement: speed from species data, stays inside zone bounds, avoids water for non-aquatic species.
4. Feeding: herbivores reduce plant biomass in their cell, scavengers eat carcasses.
5. Predation: predator can only kill prey within sizeRatioMax unless the species data marks an exception. Include a success chance (speed, hunger, prey awareness) from the predation RNG stream.
6. Death with cause recording (age, starvation, predation) and carcass creation.
7. Decomposition: carcasses decay; nutrients return to the soil ONLY if a decomposer (fungus) is alive in the zone. Without fungi, nutrients are lost and plant capacity drops slowly.

Tests to include: herbivore eats and plant biomass drops; predator kills allowed prey and never disallowed prey; size rule respected; starvation happens without food; carcass nutrients return only with fungi; no negative values; same seed same hash; ids stay ascending.

## Don't
- Do not implement reproduction, disease, competition or collapse yet (segment 5).
- Do not add species-specific branches in code.
- Do not change locked numbers listed in AGENTS.md.
- Do not tune balance. If everything dies fast, just note it in docs/progress.md.

## Definition of done
- stylua, selene, validate_data, `lune run tests/run` pass.
- Systems are separate modules under src/shared/sim/systems with a clear order in Sim.step.
- docs/progress.md updated.
- Reply in Indonesian: what each system does, any approximation you made, open issues. Then STOP.
````

---

## Segment 5: Life cycle and collapse

````text
Read AGENTS.md, then docs/architecture.md sections 4.2 (steps 8, 11, 13), 4.5, 5.2 and 11, docs/design.md sections 5.5, 5.6, 9 and 10, and docs/progress.md. Do ONLY the task below.

## Context
Animal behavior works. Now complete the life cycle, add collapse detection, the event log, and the determinism tests that protect the whole project.

## Task
1. Reproduction: needs a mate, good condition, enough food. Species data sets rate, gestation and litter. Apex predators reproduce very slowly. Respect a carrying capacity per zone.
2. Disease: chance rises with density and poor condition, using the species' susceptibility. Keep it simple for Prototype 0 (no invasive-species diseases yet).
3. Competition: based on niche overlap (shared diet and habitat). It shows up as starvation and failed breeding, never as direct kills.
4. Collapse detection (architecture.md section 4.5): animal collapse (one feeding guild left, or 2 or fewer animal species), plant collapse (below 10% of capacity), grace period of 1 season with reset when the condition clears. The score time is recorded at the moment collapse STARTS. Expose world.status (running, grace, ended) and the end reason.
5. Event log: births, deaths with cause, hunts, collapse start and end. Plus a Stats series sampled once per in-game day (population per species and per guild, plant capacity ratio).
6. Determinism tests (critical):
   - Golden seed: a fixed setup and seed give a known hash after N steps.
   - Speed invariance: stepping N steps in one batch, in batches of 1, and in mixed batch sizes gives the identical hash.
   - Invariants after long runs: no negative populations, plants never zero, no entity duplicated, dead entities never act.
   - Collapse tests for each condition, grace reset, and score time at collapse start.

## Don't
- Do not add speciation, disasters, invasive species, migration, or money.
- Do not tune balance (segment 6).
- Do not weaken a failing test to make it pass; fix the cause.

## Definition of done
- All checks pass, including golden seed and speed invariance.
- docs/progress.md updated, including the golden seed value and how to regenerate it deliberately.
- Reply in Indonesian: what was added, test results, known weaknesses. Then STOP.
````

---

## Segment 6: Balance harness

````text
Read AGENTS.md, then docs/architecture.md sections 4.5, 5 and 11, docs/design.md sections 2, 5 and 9, and docs/progress.md. Do ONLY the task below.

## Context
The simulation is complete for Prototype 0 and deterministic. Now measure it and make it playable. Tuning happens only in data files and constants, never by changing locked rules.

## Task
1. Implement tools/balance.luau (Lune): runs N seeds of the savanna pack with a default setup (and a few alternative setups, for example no decomposer, no predator, too many herbivores) and writes a JSON or CSV summary: time to collapse (in-game days), collapse reason, species alive at day 30, year 1, year 5 and year 10, extinction order, and the cause-of-death split per species.
2. Implement a performance benchmark: steps per second for 100, 300 and 600 entities in Lune. Output a table. Do not optimize yet unless a step is clearly too slow (more than 3x slower than the other systems).
3. Run the harness (at least 200 seeds per setup). Report the distribution in plain terms.
4. Tune constants in src/shared/data until the default setup meets these starting targets (they are TBD, flag any you cannot meet and explain):
   - Fewer than 5% of runs collapse within the first 30 in-game days.
   - Median collapse of the default setup falls between 2 and 20 in-game years.
   - Some but not most runs (roughly 10% to 40%) last 10 years or more.
   - Removing decomposers or all predators clearly changes the outcome.
   Keep a log of each constant you changed and why in docs/balance-notes.md.
5. Re-run golden seed tests, regenerate the golden value deliberately, and note it in docs/progress.md.

## Don't
- Do not change systems logic or locked rules to hit the targets. If the targets cannot be met with data alone, stop and describe the problem.
- Do not hide bad results. Report failures honestly.

## Definition of done
- Balance and benchmark outputs saved under tools/output (git-ignored) and summarized in docs/balance-notes.md.
- All checks pass.
- Reply in Indonesian: distribution summary, what you tuned, what you could not fix, performance numbers. Then STOP.
````

---

## Segment 7: Server session

````text
Read AGENTS.md, then docs/architecture.md sections 5, 6.1 (SessionService, SetupService, PlotService), 6.2 and 8, docs/design.md sections 3 and 5.1, and docs/progress.md. Do ONLY the task below.

## Context
The sim core is done and tested headless. Now run it on the Roblox server and send data to clients. Use the Studio MCP for verification, not for editing scripts.

## Task
1. SessionService: create a run from a validated Setup (use Setup.validate; reject invalid input with an error code), own the world, and advance it on RunService.Heartbeat. Scheduler: each session accrues steps from dt * speed (keep the fractional carry), a per-session time budget (start at 2 ms) and a global budget (start at 8 ms), round-robin between sessions. If a session cannot keep up it runs slower in real time; results never change.
2. Speeds: 1x = 1 step per real second, 10x, 50x. Only these three. Switching speed mid-run is allowed. Stop run is allowed at any time and still produces an end result.
3. PlotService (minimal): one plot per player with a spawn area. No upgrades or decorations yet.
4. Remotes with validation and rate limiting: StartRun(setup), SetSpeed(1|10|50), StopRun. The client never sends gameplay results. Reject anything malformed.
5. Replication (architecture.md section 8): RunStarted (must include the full terrain layout: grid size and the terrain type per cell), Snapshot (deltas, quantized positions, sent every N steps depending on speed), Events, Stats, PlantGrid (coarse plant biomass ratio per block of cells, for example 4x4 blocks, sent every in-game day or every few seconds, whichever is less frequent), RunEnded (raw report data: summary, population series, death causes, collapse reason). Plants are not entities, so they are never sent in Snapshot. Keep the payloads small; document the format in docs/architecture.md.
6. A Studio-only DebugService (guarded by RunService:IsStudio()) that can start a default savanna run, so you can test without UI.
7. Verify through MCP: start a playtest, start a debug run, read console output, check that snapshots are produced, that speed changes work, that Stop ends the run, and that no errors appear. Include the console output as evidence in your reply.

## Don't
- Do not build client rendering or UI (segment 8).
- Do not add money, leaderboards, or persistence.
- Do not edit Rojo-managed scripts through MCP; edit files in src/.
- Do not trust any client-sent value.

## Definition of done
- All Lune checks still pass; Studio playtest shows no errors.
- docs/architecture.md and docs/progress.md updated.
- Reply in Indonesian: what runs, measured server cost per step in Studio, issues found. Then STOP.
````

---

## Segment 8: Client and report

````text
Read AGENTS.md, then docs/architecture.md sections 7, 8 and 9, docs/design.md sections 3, 5.1, 10 and 12, and docs/progress.md. Do ONLY the task below.

## Context
Server sessions and replication work. Now make Prototype 0 playable and watchable. Keep visuals simple: the goal is to judge whether balancing is fun, not to look polished.

## Task
1. RenderController: every entity (animals, plants, fungi, carcasses) is a plain cube Part generated by code. No model assets, no Creator Store inserts, no Humanoids. Cube edge length comes from the species `size` through one scale function kept in a client config module (so sizes can be retuned in one place). Color comes from the species role (plant, herbivore, carnivore, omnivore, scavenger, decomposer) with a small per-species shade variation so species are distinguishable. Carcasses are a flat dark cube. Move cubes with CFrame or tweens and interpolate between snapshots. Keep the cube creation behind one function (for example `EntityView.create(speciesId)`), so real models can replace cubes later without touching the rest of the renderer. Level of detail by speed: 1x full movement, 10x simplified, 50x minimal markers. Cap rendered entities (start at 150) and aggregate the rest.
1b. Terrain and plants: build the ground from the terrain layout in RunStarted using plain Parts only (no meshes, no Terrain editing). One flat ground slab sized to the zone, flat blue slabs for water cells, gray cubes for rocks, and static dark-green cubes for trees. Merge adjacent cells of the same type into larger Parts so the part count stays low. Plants are NOT individual entities: show plant biomass as the ground tint, from light brown (almost none) to strong green (full capacity), updated at coarse resolution (for example 4x4 cell blocks) every time the PlantGrid update arrives. Tint changes should be smoothed with a short tween. Destroy and rebuild all terrain Parts when a new run starts or ends.
1c. Camera and layout: set a scripted camera that frames the whole zone at run start (angled top-down), with simple pan (drag or WASD) and zoom (scroll), clamped to the plot. Add a "reset camera" button. Keep UI panels from covering the zone center: setup and run controls dock to the sides, and the report appears as a full-screen overlay only after the run ends.
2. Setup UI: choose the starter pack, add families with a count up to 10 per species, optional auto-placement, and a Simulate button. Show validation errors from the server in readable text.
3. Run UI: speed buttons 1x, 10x, 50x, a Stop button, the in-game date (year, season, day), species alive count, and a live population line chart per species (use Stats data).
4. Final report screen from RunEnded data: summary (duration in in-game time, peak species count, collapse reason), population timelines, cause-of-death table per species, and a plain-language collapse explanation (a simple v0: name the species whose decline began first and the species that depended on it).
5. Verify through MCP: start a playtest, use user_mouse_input and user_keyboard_input to click through setup and Simulate, capture screenshots at 1x and 50x and of the report, and check console output for errors. Include the evidence in your reply.
6. Write docs/prototype0-playtest.md: how to run Prototype 0, what works, what is missing, and 5 questions for the human playtest (Is balancing fun? Do failures feel fair? Is the report useful? Is 1x worth watching? Is 50x too fast to learn?).

## Don't
- Do not add money, index, leaderboards, upgrades, or anything outside Prototype 0 scope.
- Do not spend time on art or polish.
- Do not use meshes, textures, lighting effects, or the Roblox Terrain system. Plain Parts only.
- Do not make one Part per plant or per grid cell when merging is possible.
- Do not edit Rojo-managed scripts through MCP.

## Definition of done
- All checks pass; a full run (setup, simulate, report) works in a playtest with no console errors.
- Terrain, plant tint, and camera are visible in the screenshots, and the ground part count is reported.
- docs/progress.md and docs/prototype0-playtest.md updated.
- Reply in Indonesian: what the user can now do, screenshots/evidence, known gaps. Then STOP.
````

---

## Prototype 0 exit review (for you, not the agent)

After segment 8, play it yourself for 20 to 30 minutes and answer:

1. Did you want to try again after a collapse?
2. Did you understand why the ecosystem collapsed from the report?
3. Did changing the setup change the outcome in a way you could learn from?
4. Was 1x worth watching, and was 50x too fast to learn from?
5. What would you most want to add next?

If the answers to 1 to 3 are mostly yes, move on to Phase 1 (money, upgrades, index). If not, fix the core loop before adding anything else.
