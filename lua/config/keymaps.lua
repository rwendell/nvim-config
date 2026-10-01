vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")


vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "=ap", "ma=ap'a")

vim.keymap.set("x", "<leader>p", [["_dP]])

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Project-wide fixes, one keypress (`<leader>caa`). Linter/formatter agnostic:
-- each entry names marker files to find a project root, then commands to run
-- there. A project can match several entries (e.g. eslint + prettier); all
-- matching entries run, lint-fixers before formatters. Needs no attached
-- client. Java has no reliable CLI fixer, so Java projects are `cc`-only.
local project_fixers = {
	{
		name = "eslint",
		markers = {
			"eslint.config.js",
			"eslint.config.mjs",
			"eslint.config.cjs",
			"eslint.config.ts",
			".eslintrc",
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.json",
			".eslintrc.yml",
			".eslintrc.yaml",
		},
		runs = { { bin = "eslint", args = { "--fix", "." }, node = true } },
	},
	{
		name = "biome",
		markers = { "biome.json", "biome.jsonc" },
		runs = { { bin = "biome", args = { "check", "--write", "." }, node = true } },
	},
	{
		name = "prettier",
		markers = {
			".prettierrc",
			".prettierrc.json",
			".prettierrc.yml",
			".prettierrc.yaml",
			".prettierrc.json5",
			".prettierrc.js",
			".prettierrc.cjs",
			".prettierrc.mjs",
			".prettierrc.toml",
			"prettier.config.js",
			"prettier.config.cjs",
			"prettier.config.mjs",
		},
		runs = { { bin = "prettier", args = { "--write", "." }, node = true } },
	},
	{
		name = "cargo",
		markers = { "Cargo.toml" },
		runs = {
			{ bin = "cargo", args = { "clippy", "--fix", "--allow-dirty", "--allow-staged" } },
			{ bin = "cargo", args = { "fmt" } },
		},
	},
}

-- Python: ruff when configured (or the only one available), else black.
local function python_fixer(start)
	local find_up = function(names)
		return vim.fs.find(names, { path = start, upward = true, type = "file", limit = 1 })[1]
	end
	local ruff_cfg = find_up({ "ruff.toml", ".ruff.toml" })
	local pyproject = find_up({ "pyproject.toml" })
	local wants_ruff, wants_black = ruff_cfg ~= nil, false
	if pyproject and not wants_ruff then
		for _, line in ipairs(vim.fn.readfile(pyproject, "", 60)) do
			if line:match("^%[tool%.ruff%]") then
				wants_ruff = true
				break
			end
			if line:match("^%[tool%.black%]") then
				wants_black = true
				break
			end
		end
	end
	local marker = ruff_cfg
		or pyproject
		or find_up({ "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "poetry.lock" })
	if not marker then
		return nil
	end
	local root = vim.fs.dirname(marker)
	if wants_black and vim.fn.executable("black") == 1 then
		return { name = "black", root = root, runs = { { bin = "black", args = { "--quiet", "." } } } }
	end
	if wants_ruff or vim.fn.executable("ruff") == 1 then
		return {
			name = "ruff",
			root = root,
			runs = {
				{ bin = "ruff", args = { "check", "--fix", "." } },
				{ bin = "ruff", args = { "format", "." } },
			},
		}
	end
	if vim.fn.executable("black") == 1 then
		return { name = "black", root = root, runs = { { bin = "black", args = { "--quiet", "." } } } }
	end
	return nil
end

local function resolve_bin(root, run)
	if run.node then
		local local_bin = vim.fs.find(
			"node_modules/.bin/" .. run.bin,
			{ path = root, upward = true, type = "file", limit = 1 }
		)[1]
		if local_bin and vim.fn.executable(local_bin) == 1 then
			return local_bin
		end
	end
	return run.bin
end

local function project_fix_all()
	local start = vim.fn.getcwd()
	local current = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
	if current ~= "" then
		start = vim.fs.dirname(current)
	end
	local reports = {}
	local ran_any = false
	local function run_at(root, name, runs)
		for _, run in ipairs(runs) do
			local bin = resolve_bin(root, run)
			if vim.fn.executable(bin) ~= 1 then
				table.insert(reports, name .. ": skipped (" .. run.bin .. " not found)")
			else
				local cmd = { bin, unpack(run.args) }
				local result = vim.system(cmd, { cwd = root, text = true }):wait(120000)
				ran_any = true
				if result.code == 0 then
					table.insert(reports, name .. ": ok")
				else
					local output = (result.stderr ~= "" and result.stderr or result.stdout):gsub("%s+$", "")
					local tail = table.concat(vim.list_slice(vim.split(output, "\n"), -3), "\n")
					table.insert(reports, name .. ": issues:\n" .. tail)
				end
			end
		end
	end
	for _, fixer in ipairs(project_fixers) do
		local marker = vim.fs.find(
			fixer.markers,
			{ path = start, upward = true, type = "file", limit = 1 }
		)[1]
		if marker then
			run_at(vim.fs.dirname(marker), fixer.name, fixer.runs)
		end
	end
	local python = python_fixer(start)
	if python then
		run_at(python.root, python.name, python.runs)
	end
	if not ran_any and #reports == 0 then
		vim.notify(
			"No supported fixer found (biome/eslint/prettier/cargo/ruff/black).",
			vim.log.levels.WARN
		)
		return
	end
	vim.cmd("checktime")
	vim.notify(table.concat(reports, "\n"), vim.log.levels.INFO)
end

-- `<leader>cA`, not `<leader>caa`: `ca` must not be a prefix of another
-- mapping, or every plain code-action (`ca`) pays `timeoutlen` waiting.
vim.keymap.set("n", "<leader>cA", project_fix_all)
