# Progress

## Current segment
(none — segment 1 finished; next: sim core skeleton)

## Done
- Segment 1, 2026-10-11: Module-loading convention picked and proven identical in Lune and Studio; `src/shared/util/Rng.luau` (xorwow) and `Hash.luau` (FNV-1a 32-bit) implemented with golden-vector tests; `tests/run.luau` runner added (15 passing); cross-runtime equality proven via Studio MCP playtest.

## Decisions
- Module loading = relative string requires (`./`, `../`) between plain modules in `src/shared`; no `script.Parent.X`, no loader shim; no `init.luau` modules inside `src/shared` (Roblox and Lune disagree on `./` semantics from an init module); `@lune/*` only in `tests/` and `tools/`. Reason: Roblox resolves relative string requires by instance navigation, Lune by file location, and for plain files under one mapped root the two are identical — verified bit-identical output on both runtimes. (segment 1)
- PRNG = Marsaglia xorshift32 + Weyl counter (xorwow style), integer-only via `bit32`/exact f64 ops; streams derived with FNV-1a via `Rng.derive(seed, systemId, step)`. Hash = FNV-1a 32-bit with exact 16-bit-limb multiplication (a direct multiply would lose low bits above 2^53 in f64). (segment 1)

## Conventions
- Module loading: relative string requires in `src/` (`./sibling`, `../dir/module`); randomness only through `shared/util/Rng` streams, never `math.random`; stable checksums through `shared/util/Hash`. (segment 1)

## Open issues
- (none yet)

## Data review needed
- (see docs/data-review.md)
