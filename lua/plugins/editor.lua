local function project_root()
	return vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
end

local function search_picker(mode, query)
	local next_mode = mode == "files" and "grep" or "files"
	local next_label = next_mode == "files" and "Files" or "Grep"
	local label = mode == "files" and "Files" or "Grep"
	local opts = {
		cwd = project_root(),
		search = query,
		title = label .. " (<C-g> for " .. next_label .. ")",
		actions = {
			toggle_search = function(picker)
				local search = picker.input:get()
				picker:close()
				vim.schedule(function() search_picker(next_mode, search) end)
			end,
		},
		win = {
			input = {
				keys = {
					["<C-g>"] = { "toggle_search", mode = { "i", "n" }, desc = "Toggle Files/Grep" },
				},
			},
		},
	}

	if mode == "files" then
		Snacks.picker.files(opts)
	else
		Snacks.picker.grep(opts)
	end
end

return {
	{
		'stevearc/oil.nvim',
		lazy = false,
		opts = {},
		keys = {
			{ "<leader>fc", "<cmd>Oil<cr>", desc = "View Current Directory" }
		},
		dependencies = { "echasnovski/mini.icons", "nvim-tree/nvim-web-devicons" },
	},
	{
		'echasnovski/mini.files',
		keys = {
			{ "<leader>ft", function() require("mini.files").open(vim.api.nvim_buf_get_name(0), true) end, desc = "view File Tree" }
		}
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {},
		-- stylua: ignore
		keys = {
			{ "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
			{ "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
			{ "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
			{ "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signcolumn = false,
			numhl = true,
		},
	},
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			menu = { width = vim.api.nvim_win_get_width(0) - 4, },
			settings = { save_on_toggle = true, },
		},
		keys = function()
			local keys = {
				{
					"<leader>hH",
					function() require("harpoon"):list():add() end,
					desc = "Harpoon File",
				},
				{
					"<leader>hh",
					function()
						local harpoon = require("harpoon")
						require("harpoon").ui:toggle_quick_menu(harpoon:list())
					end,
					desc = "Harpoon Quick Menu",
				},
			}

			for i = 1, 5 do
				table.insert(keys, {
					"<leader>h" .. i,
					function() require("harpoon"):list():select(i) end,
					desc = "Harpoon to File " .. i,
				})
			end
			return keys
		end,
	},

	{
		"folke/snacks.nvim",
		keys = {
			{ "<leader>u", function() Snacks.picker.undo() end, desc = "Undotree" },
			-- find and search
			{ "<leader>sf",     function() search_picker("files") end,        desc = "Search Files/Grep (<C-g> toggles)" },
			{ "<leader>,",      function() Snacks.picker.buffers() end,       desc = "Buffers" },
			{ "<leader>:",      function() Snacks.picker.command_history() end, desc = "Command History" },
			{ "<leader>sb", function() Snacks.picker.lines() end,           desc = "Buffer Lines" },
			{ "<leader>sB", function() Snacks.picker.grep_buffers() end,    desc = "Grep Open Buffers" },
		}
	},
	{
		"folke/trouble.nvim",
		dependencies = { "folke/snacks.nvim" },
		cmd = "Trouble",
		init = function()
			local ok, treesitter = pcall(require, "trouble.view.treesitter")
			if not ok then
				return
			end
			local TSHighlighter = vim.treesitter.highlighter
			local function wrap(name)
				return function(...)
					if not treesitter.cache[select(2, ...)] then
						return false
					end
					local fn = TSHighlighter[name]
					if not fn then
						return false
					end
					local active = TSHighlighter.active
					for _, hl in pairs(treesitter.cache[select(2, ...)] or {}) do
						if hl.enabled then
							active[select(2, ...)] = hl.highlighter
							fn(...)
						end
					end
					active[select(2, ...)] = nil
				end
			end
			treesitter.wrap = wrap
		end,
		opts = {
			focus = true,
			auto_close = true,
			warn_no_results = false,
			win = { type = "split", size = 6 },
		},
		keys = { { "<leader>ct", "<cmd>Trouble diagnostics <cr>" } }
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		dependencies = { "echasnovski/mini.icons", "nvim-tree/nvim-web-devicons" },
		opts = {
			icons = {
				rules = {
					{ pattern = "%f[%a]tree", icon = "󰙅" },
					{ plugin = "oil.nvim", icon = "󱄯" },
				}
			},
			spec = {
				{ "<leader>f", group = "file" },
				{ "<leader>h", group = "harpoon", icon = "󰛢" },
				{ "<leader>N", icon = "" },
				{ "<leader>s", group = "search", icon = "󱥰" },
				{ "<leader>u", icon = "" },
				{ "<Leader>g", group = "git" },
			}
		},
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "folke/trouble.nvim" },
		opts = {}
	}
}
