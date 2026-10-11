--!strict
-- Seeded PRNG for the deterministic simulation core. Never use math.random anywhere in
-- src/shared: every random decision must come from an Rng stream so that a run seeded,
-- set up, and driven by the same command log can be replayed exactly.
--
-- Algorithm (xorwow style, 32-bit):
--   x ^= x << 13;  x ^= x >> 17;  x ^= x << 5   (Marsaglia's xorshift32, period 2^32 - 1)
--   w += 362437 (mod 2^32)                      (Weyl counter)
--   output = (x + w) mod 2^32
-- Every transition uses bit32 or exact integer arithmetic, so outputs are bit-identical
-- in Roblox and Lune. Not cryptographic; adequate for game simulation.
--
-- Streams are derived by hashing (seed, ...) with FNV-1a (see Hash.luau), so nearby seeds
-- and per-system, per-step streams (Rng.derive(seed, systemId, step)) look independent,
-- and the all-zero xorshift state is impossible.

local Hash = require("./Hash")

local WEYL_CONSTANT = 362437
local POW32 = 2 ^ 32
local FLOAT_SCALE = 2 ^ 24
local ZERO_FALLBACK = 0x9E3779B9

local Rng = {}
Rng.__index = Rng

export type Rng = typeof(setmetatable({} :: { _x: number, _w: number }, Rng))

-- Create an independent stream from a seed plus any ordered mix of numbers and strings,
-- for example Rng.derive(seed, "movement", step). Same inputs always yield the same
-- stream; different inputs yield unrelated streams.
function Rng.derive(seed: number, ...: number | string): Rng
	local h = Hash.new()
	h:add(seed)
	for i = 1, select("#", ...) do
		local part = select(i, ...)
		h:add(part)
	end
	local x = h:finish()
	if x == 0 then
		x = ZERO_FALLBACK
	end
	-- Derive the Weyl counter start separately so it is not trivially related to x.
	local wh = Hash.new()
	wh:add(x)
	wh:add("weyl")
	return setmetatable({ _x = x, _w = wh:finish() } :: { _x: number, _w: number }, Rng)
end

-- A stream from a single seed. Any finite number is accepted and hashed, so seed and
-- seed + 1 produce unrelated streams and a zero seed is safe.
function Rng.new(seed: number): Rng
	return Rng.derive(seed)
end

-- Raw 32-bit draw. Internal; the public API is nextInt, nextFloat, and chance.
function Rng._nextU32(self: Rng): number
	local x = self._x
	x = bit32.bxor(x, bit32.lshift(x, 13))
	x = bit32.bxor(x, bit32.rshift(x, 17))
	x = bit32.bxor(x, bit32.lshift(x, 5))
	self._x = x
	self._w = (self._w + WEYL_CONSTANT) % POW32
	return (x + self._w) % POW32
end

-- Uniform integer in [0, n). Rejection-sampled, so there is no modulo bias for any n.
-- n must be an integer in [1, 2^32].
function Rng.nextInt(self: Rng, n: number): number
	assert(n % 1 == 0 and n >= 1 and n <= POW32, "Rng.nextInt: n must be an integer in [1, 2^32]")
	local limit = POW32 - (POW32 % n)
	local r = self:_nextU32()
	while r >= limit do
		r = self:_nextU32()
	end
	return r % n
end

-- Uniform float in [0, 1), built from the top 24 bits of one draw.
function Rng.nextFloat(self: Rng): number
	return bit32.rshift(self:_nextU32(), 8) / FLOAT_SCALE
end

-- True with probability p, for p in [0, 1]. p <= 0 is always false and p >= 1 is always
-- true; neither consumes a draw, which keeps stream positions predictable.
function Rng.chance(self: Rng, p: number): boolean
	assert(p >= 0 and p <= 1, "Rng.chance: p must be in [0, 1]")
	if p <= 0 then
		return false
	elseif p >= 1 then
		return true
	end
	return self:nextFloat() < p
end

return Rng
