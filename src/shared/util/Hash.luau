--!strict
-- Stable 32-bit FNV-1a hash for world-state checksums and RNG stream derivation.
--
-- Algorithm: standard FNV-1a (32-bit). The state starts at the FNV offset basis
-- 2166136261 and, for every input byte, becomes (state XOR byte) * 16777619 with all
-- arithmetic taken modulo 2^32. Feeding is streaming: add("he"), add("llo") hashes the
-- same bytes as add("hello"). Strings are fed byte by byte; numbers are fed as their
-- 8-byte little-endian IEEE-754 f64 encoding, so every finite number hashes identically
-- on every platform. NaN payloads are platform-dependent: never hash NaN.
--
-- Not cryptographic. The 32x32-bit multiply is computed with exact 16-bit-limb
-- arithmetic because Luau numbers are f64 and a direct multiply silently loses low bits
-- once a product exceeds 2^53. All outputs are therefore bit-identical in Roblox and Lune.

local POW32 = 2 ^ 32
local FNV_OFFSET_BASIS = 2166136261
local FNV_PRIME = 16777619

local Hash = {}
Hash.__index = Hash

export type Hash = typeof(setmetatable({} :: { _state: number }, Hash))

-- Reused scratch buffer so feeding a number allocates nothing.
local numBuf = buffer.create(8)

-- Exact (a * b) % 2^32 for a and b in [0, 2^32). Each partial product stays below
-- 2^33, which f64 represents exactly, so no bits are ever lost.
local function mul32(a: number, b: number): number
	local aLo = a % 65536
	local aHi = (a - aLo) / 65536
	local bLo = b % 65536
	local bHi = (b - bLo) / 65536
	local cross = aHi * bLo + aLo * bHi
	local low = aLo * bLo
	return (low + (cross % 65536) * 65536) % POW32
end

function Hash.new(): Hash
	return setmetatable({ _state = FNV_OFFSET_BASIS } :: { _state: number }, Hash)
end

-- Feed one value in order. Returns self so feeds can be chained.
function Hash.add(self: Hash, value: number | string): Hash
	local state = self._state
	if type(value) == "string" then
		for i = 1, #value do
			state = mul32(bit32.bxor(state, string.byte(value, i)), FNV_PRIME)
		end
	else
		buffer.writef64(numBuf, 0, value)
		for i = 0, 7 do
			state = mul32(bit32.bxor(state, buffer.readu8(numBuf, i)), FNV_PRIME)
		end
	end
	self._state = state
	return self
end

-- Final 32-bit value. The hasher stays usable; finish does not reset the state.
function Hash.finish(self: Hash): number
	return self._state
end

return Hash
