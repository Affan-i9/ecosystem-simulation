--!strict
-- Minimal Lune test runner. Discovers every *_test.luau under tests/, runs each test it
-- exports ({ name = string, fn = function }), prints PASS/FAIL per test, and exits
-- non-zero when anything fails. Run with: lune run tests/run

local fs = require("@lune/fs")
local process = require("@lune/process")

export type TestCase = {
	name: string,
	fn: () -> (),
}

local SUFFIX = "_test.luau"
local EXTENSION = ".luau"

local function collect(dir: string, relDir: string, out: { string })
	for _, entry in fs.readDir(dir) do
		local child = dir .. "/" .. entry
		local rel = relDir .. entry
		if fs.isDir(child) then
			collect(child, rel .. "/", out)
		elseif string.sub(entry, -#SUFFIX) == SUFFIX then
			table.insert(out, rel)
		end
	end
end

local files = {}
collect("tests", "", files)
table.sort(files)

if #files == 0 then
	print("no test files found under tests/")
	process.exit(1)
end

local passed = 0
local failed = 0

for _, rel in files do
	-- Strip the extension and require relative to this file (tests/run.luau).
	local modulePath = "./" .. string.sub(rel, 1, -(#EXTENSION + 1))
	local loaded, mod = pcall(require, modulePath)
	if not loaded then
		failed += 1
		print(("[FAIL] %s (module failed to load: %s)"):format(rel, tostring(mod)))
		continue
	end

	local tests = mod :: { TestCase }
	for _, test in tests do
		local ok, err = pcall(test.fn)
		if ok then
			passed += 1
			print(("[PASS] %s: %s"):format(rel, test.name))
		else
			failed += 1
			print(("[FAIL] %s: %s"):format(rel, test.name))
			print("       " .. tostring(err))
		end
	end
end

print(("\n%d passed, %d failed"):format(passed, failed))
if failed > 0 then
	process.exit(1)
end
