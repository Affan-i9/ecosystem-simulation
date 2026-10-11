--!strict
-- String vectors are the published FNV-1a 32-bit reference vectors (draft-eastlake-fnv).
-- Number vectors were generated from this implementation under Lune and cross-checked
-- against Roblox Studio via MCP (see docs/progress.md).

local Hash = require("../../src/shared/util/Hash")

return {
	{
		name = "published FNV-1a vectors for strings",
		fn = function()
			assert(Hash.new():finish() == 2166136261, "empty input must equal the FNV offset basis")
			assert(Hash.new():add("a"):finish() == 3826002220, "vector for 'a' mismatch")
			assert(Hash.new():add("b"):finish() == 3876335077, "vector for 'b' mismatch")
			assert(Hash.new():add("foobar"):finish() == 3214735720, "vector for 'foobar' mismatch")
		end,
	},
	{
		name = "streaming: split feeds equal one whole-string feed",
		fn = function()
			local whole = Hash.new():add("hello"):finish()
			local split = Hash.new():add("he"):add("ll"):add("o"):finish()
			assert(whole == split, "split feeds diverged from the whole-string feed")
		end,
	},
	{
		name = "feed order changes the result",
		fn = function()
			assert(
				Hash.new():add("a"):add("b"):finish() ~= Hash.new():add("b"):add("a"):finish(),
				"'a' then 'b' must differ from 'b' then 'a'"
			)
			assert(
				Hash.new():add(1):add("x"):finish() ~= Hash.new():add("x"):add(1):finish(),
				"number-then-string must differ from string-then-number"
			)
		end,
	},
	{
		name = "numbers and strings with the same text hash differently",
		fn = function()
			assert(
				Hash.new():add(1):finish() ~= Hash.new():add("1"):finish(),
				"1 and '1' must hash differently"
			)
		end,
	},
	{
		name = "golden vectors for numbers",
		fn = function()
			assert(Hash.new():add(0):finish() == 2615243109, "vector for 0 mismatch")
			assert(Hash.new():add(1):finish() == 2355796088, "vector for 1 mismatch")
			assert(Hash.new():add(-1):finish() == 208260856, "vector for -1 mismatch")
			assert(Hash.new():add(3.5):finish() == 2479050681, "vector for 3.5 mismatch")
			assert(Hash.new():add(12345):finish() == 3190171977, "vector for 12345 mismatch")
		end,
	},
	{
		name = "same feed in the same order is reproducible",
		fn = function()
			local function feed(): number
				return Hash.new():add("eco"):add(12):add("step"):add(-0.5):finish()
			end
			assert(feed() == feed(), "repeated identical feed gave different results")
		end,
	},
}
