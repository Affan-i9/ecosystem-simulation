# AGENTS.md

Instructions for AI coding agents (opencode) working in this repository.

## Project

Ecosystem Terrarium (working title): a Roblox tycoon-style ecosystem simulator written in Luau. Each player has a terrarium, picks plant and animal families, runs a simulation, and watches the food web play out. Money, leaderboards, and a taxonomy index come from how long and how diverse the ecosystem survives. This repo targets **complex mode** first (scientifically accurate, no pay-to-win).

Read before coding:

- `docs/design.md`: gameplay rules (source of truth for behavior)
- `docs/architecture.md`: code structure and technical decisions (source of truth for structure)

If a task conflicts with either file, stop and ask instead of guessing.

## Language

- Talk to the user in **Indonesian**.
- Code, identifiers, comments, commit messages, and docs in this repo are in **English**.
- Species display names may include Indonesian common names in data files.

## Tech stack

- Luau with strict typing (`--!strict` at the top of every module)
- **Rojo** syncs files in `src/` into Roblox Studio (`default.project.json`). Files are the source of truth for all scripts.
- **Roblox Studio MCP (built into Studio)** is how you act inside the open Studio session: playtest, console, screenshots, input simulation, instances, assets.
- **Rokit** pins tool versions (`rokit.toml`): Rojo, Lune, StyLua, Selene.
- Lune for headless tests and tools
- StyLua for formatting, Selene for linting
- Wally for packages (only add one when there is a clear need)

Check `rokit.toml` and `wally.toml` for the real versions before running commands. If a tool is missing, run `rokit install`.

## Commands

Adjust to the real scripts if they differ.

```bash
rokit install                      # install pinned tools
rojo serve                         # live sync to Studio (keep running while working)
rojo build -o build/game.rbxl      # build place file
rojo sourcemap default.project.json -o sourcemap.json   # for editor tooling
stylua src tests tools             # format
selene src tests tools             # lint
lune run tests/run                 # run all headless tests
lune run tools/validate_data       # validate species and biome data
lune run tools/balance <pack> <n>  # balance harness over n seeds
```

Before finishing any task, run format, lint, data validation (if data changed), and tests. Report failures honestly; do not claim a check passed if it was not run.

## Roblox Studio MCP and Rojo: who does what

The Studio MCP server is configured in `opencode.json` under the name `roblox_studio`. Tool names below come from Roblox's built-in server; if a tool is missing, list the available tools instead of guessing.

| Task | Use |
|---|---|
| Create, edit, delete scripts under `src/` | Files (Rojo syncs them). **Never** use `multi_edit` on these. |
| Read scripts | Files first. `script_read` / `script_grep` only to check what Studio actually has. |
| Run headless tests | Lune |
| Playtest, read console output | `start_stop_play`, `get_console_output`, `get_studio_state` |
| Check visuals | `screen_capture` |
| Simulate a player | `character_navigation`, `user_keyboard_input`, `user_mouse_input` |
| Inspect instances | `search_game_tree`, `inspect_instance` |
| Quick experiments in Studio | `execute_luau` (specify `datamodel_type`: Edit, Client, or Server) |
| Build models, UI, plots, terrain, assets | MCP tools (`generate_procedural_model`, `search_asset`, `insert_asset`, `execute_luau`) |
| Roblox API and docs lookup | `http_get`, `skill` |

Rules:

1. Scripts managed by Rojo are edited as files only. Changes made inside Studio to those scripts are overwritten on the next sync.
2. Before using MCP, confirm `rojo serve` is running and Studio shows the Rojo connection. Use `list_roblox_studios` and pass the right `studio_id` when more than one Studio is open.
3. `execute_luau` in Edit mode changes the open place. Do not run destructive code (deleting services, clearing Workspace, mass renames) without asking the user.
4. Things built in Studio (models, UI, terrain, decorations) live in the place, not in `src/`. Keep them out of Rojo-managed paths and tell the user what you built and where, so it can be saved from Studio.
5. Do not use `execute_luau` to bypass a failing test. Fix the code in `src/`.
6. Gameplay checks through MCP (playtest) complement Lune tests and never replace them.

## Repository map

- `default.project.json`: Rojo project (maps `src/` into the DataModel)
- `rokit.toml`: pinned tools; `opencode.json`: opencode and MCP config
- `src/shared/sim/`: pure simulation core
- `src/shared/data/`: species, biomes, starter packs, disasters (plain tables)
- `src/shared/types/`, `src/shared/util/`: types, RNG, hashing, math
- `src/server/`: services (sessions, economy, leaderboards, trade, sabotage)
- `src/client/`: rendering, UI, input
- `tests/`, `tools/`: Lune tests, validators, balance harness

## Hard rules

These come from locked design decisions. Do not break them without asking.

1. **Determinism.** `src/shared/sim` must never use `math.random`, `os.time`, `os.clock`, `tick`, `task`, `game`, `workspace`, or any Roblox service. Use the seeded RNG from `shared/util`. Never let `pairs` iteration order affect results; iterate arrays by ascending id.
2. **Speed must not change results.** The sim advances in fixed steps of 1 in-game hour. Speeds are 1x, 10x, 50x only. Speed changes how many steps run per real second and nothing else. No Turbo, no Instant in complex mode.
3. **Server authoritative.** Clients never decide gameplay results. Validate every remote on the server and rate-limit it.
4. **Data-driven species.** Adding a species means adding a data entry and running the validator. Never write species-specific code paths (`if species == "Panthera leo"`).
5. **No Humanoids for animals.** Use lightweight objects moved by CFrame or tweens. For now every entity (animal, plant, fungus, carcass) is a plain cube Part sized by species `size` and colored by role. Do not insert or generate models or meshes unless asked. Create cubes through one factory (`EntityView.create`) so models can replace them later.
6. **Logic and visuals stay separate.** The sim knows nothing about models, parts, or the camera. The client renders from snapshots and events.
7. **External input to a run is a command** stamped with a step. Disasters and sabotage are commands. Keep run setup, seed, and command log reproducible.
8. **No pay-to-win in complex mode.** Robux can only buy cosmetics and decorations there. Never wire Robux into sim, income, or leaderboard logic. Sabotage uses in-game money only.
9. **Scientific accuracy.** Taxonomy, diet, habitat, region, and IUCN status come from real sources. Mark guessed values as estimates in data. Do not invent species relationships to make things convenient.
10. **Plants never go fully extinct** (seed bank floor). Bacteria and archaea are not simulated.
11. **Files are the source of truth for scripts.** Edit `src/` as files and let Rojo sync. Do not edit Rojo-managed scripts through Studio MCP tools.

## Locked gameplay numbers (change only with approval)

- 1 real second at 1x = 1 in-game hour
- Max 10 starting individuals per species; family placement, species chosen by seed
- Collapse grace period 1 season (90 in-game days), plant collapse below 10% zone capacity
- Ranked runs: 10x or 50x only; 1 best run counts; entry fee in in-game money
- 1x runs never reach leaderboards
- Offline exhibit income capped at 8 hours
- One sabotage per saboteur per run, opt-in targets only

Numbers labeled "default" or "TBD" in the design doc are tunable. Put tunable constants in `src/shared/data/` and never hardcode them in logic.

## Code conventions

- One module, one responsibility. Keep functions short and typed.
- Export types from `shared/types`. Avoid `any`.
- Prefer plain tables and arrays in the sim core for performance (struct-of-arrays for entities).
- Name files `PascalCase.luau` for classes and services, `camelCase.luau` for plain modules.
- No global state. Pass `World` and context explicitly.
- Public service methods validate their inputs. Internal sim functions assume validated input.
- Comments explain why, not what.
- No new dependency without a short justification in the PR or commit message.

## Testing expectations

- Every new sim system needs a test: golden seed or invariant.
- Any change touching `shared/sim` must keep the speed-invariance test passing (same world hash regardless of how steps are batched).
- Any data change must pass `validate_data`.
- Balance-affecting changes should include before and after output from the balance harness.

## Workflow

- Work in small, reviewable steps. Describe the plan briefly, then implement.
- Typical loop: edit files in `src/`, run Lune tests, let Rojo sync, then verify in Studio through MCP (playtest, console, screenshot).
- Prefer the current phase from `docs/architecture.md` section 12. Do not build Phase 3 features while Phase 0 is unfinished.
- Don't refactor unrelated code in the same change.
- Update `docs/architecture.md` when you change structure, and flag any design conflict in `docs/design.md` instead of silently editing it.
- Ask the user when a decision is not covered by the docs. Offer 2 or 3 concrete options with a recommendation.
- Do not delete or rewrite files in `docs/` without being asked.

## Security and fairness

- Never trust client values (position, hunger, money, speed, run results).
- Trade, rating, and sabotage need server-side limits to prevent alt-account abuse.
- Do not log player data beyond what is needed.

## Definition of done

1. Code follows the hard rules above.
2. Format, lint, tests, and data validation pass (or failures are reported clearly).
3. For anything visible or networked, a Studio playtest through MCP was run and the console output was checked for errors (or you state clearly that it was not possible).
4. Docs updated if structure or rules changed.
5. A short summary in Indonesian: what changed, what was tested, what is still open.
