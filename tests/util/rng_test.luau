--!strict
-- Golden vectors were generated from this implementation under Lune and are cross-checked
-- against Roblox Studio via MCP (see docs/progress.md). If a vector ever changes, both
-- runtimes must be re-verified before updating it here.

local Rng = require("../../src/shared/util/Rng")

local function sequencesEqual(a: Rng, b: Rng, count: number, bound: number): boolean
	for _ = 1, count do
		if a:nextInt(bound) ~= b:nextInt(bound) then
			return false
		end
	end
	return true
end

return {
	{
		name = "golden vector: Rng.new(12345), first five nextInt(1000)",
		fn = function()
			local r = Rng.new(12345)
			local expected = { 373, 94, 224, 726, 298 }
			for i = 1, #expected do
				assert(r:nextInt(1000) == expected[i], ("draw %d mismatch"):format(i))
			end
		end,
	},
	{
		name = "golden vector: Rng.new(12345), first five nextFloat()",
		fn = function()
			local r = Rng.new(12345)
			-- Literals printed with %.17g, so they round-trip to the exact f64 values.
			local expected = {
				0.22042083740234375,
				0.889900803565979,
				0.44733589887619019,
				0.73288673162460327,
				0.28119170665740967,
			}
			for i = 1, #expected do
				assert(r:nextFloat() == expected[i], ("draw %d mismatch"):format(i))
			end
		end,
	},
	{
		name = "same seed gives identical sequences, different seeds differ",
		fn = function()
			assert(
				sequencesEqual(Rng.new(777), Rng.new(777), 200, 97),
				"same seed gave different sequences"
			)
			assert(
				not sequencesEqual(Rng.new(777), Rng.new(778), 200, 97),
				"seeds 777 and 778 produced identical sequences"
			)
		end,
	},
	{
		name = "derive is deterministic, order-sensitive, and streams are independent",
		fn = function()
			assert(
				sequencesEqual(Rng.derive(777, "env", 12), Rng.derive(777, "env", 12), 50, 1000),
				"derive with identical inputs gave different streams"
			)
			assert(
				not sequencesEqual(
					Rng.derive(777, "env", 12),
					Rng.derive(777, "hunt", 12),
					50,
					1000
				),
				"different system ids produced identical streams"
			)
			assert(
				not sequencesEqual(Rng.derive(777, 1, 2), Rng.derive(777, 2, 1), 50, 1000),
				"part order did not affect the stream"
			)
			assert(
				not sequencesEqual(Rng.derive(777, 1, 2), Rng.derive(777, 12), 50, 1000),
				"grouping of parts did not affect the stream"
			)
			assert(
				not sequencesEqual(Rng.derive(1, "x"), Rng.derive(2, "x"), 50, 1000),
				"different seeds produced identical derived streams"
			)
			-- Golden vectors for derived streams.
			local env = Rng.derive(777, "env", 12)
			assert(env:nextInt(1000) == 319, "env draw 1 mismatch")
			assert(env:nextInt(1000) == 520, "env draw 2 mismatch")
			assert(env:nextInt(1000) == 739, "env draw 3 mismatch")
			local hunt = Rng.derive(777, "hunt", 12)
			assert(hunt:nextInt(1000) == 993, "hunt draw 1 mismatch")
			assert(hunt:nextInt(1000) == 79, "hunt draw 2 mismatch")
			assert(hunt:nextInt(1000) == 650, "hunt draw 3 mismatch")
		end,
	},
	{
		name = "nextInt stays in [0, n) for many bounds, and nextInt(1) is always 0",
		fn = function()
			local r = Rng.new(2026)
			for _, bound in { 1, 2, 3, 7, 100, 1000, 100000 } do
				for _ = 1, 500 do
					local v = r:nextInt(bound)
					assert(v >= 0 and v < bound, ("out of range for bound %d: %d"):format(bound, v))
				end
			end
			local ones = Rng.new(5)
			for _ = 1, 100 do
				assert(ones:nextInt(1) == 0, "nextInt(1) returned a nonzero value")
			end
		end,
	},
	{
		name = "nextFloat stays in [0, 1)",
		fn = function()
			local r = Rng.new(99)
			for _ = 1, 1000 do
				local v = r:nextFloat()
				assert(v >= 0 and v < 1, ("out of range: %f"):format(v))
			end
		end,
	},
	{
		name = "chance(0) is never true and chance(1) is always true",
		fn = function()
			local r = Rng.new(7)
			for _ = 1, 100 do
				assert(r:chance(0) == false, "chance(0) returned true")
				assert(r:chance(1) == true, "chance(1) returned false")
			end
		end,
	},
	{
		name = "chance(0.5) lands near half over 10000 draws",
		fn = function()
			local r = Rng.new(42)
			local trues = 0
			for _ = 1, 10000 do
				if r:chance(0.5) then
					trues += 1
				end
			end
			assert(trues >= 4700 and trues <= 5300, ("got %d true of 10000"):format(trues))
		end,
	},
	{
		name = "zero seed yields a usable stream distinct from seed 1",
		fn = function()
			local z = Rng.new(0)
			for _ = 1, 10 do
				local v = z:nextInt(1000)
				assert(v >= 0 and v < 1000, ("out of range for zero seed: %d"):format(v))
			end
			assert(
				not sequencesEqual(Rng.new(0), Rng.new(1), 50, 1000),
				"seeds 0 and 1 produced identical streams"
			)
		end,
	},
}
