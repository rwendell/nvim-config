return {
	{
		'nvim-lualine/lualine.nvim',
		event = "VeryLazy",
		dependencies = { 'nvim-tree/nvim-web-devicons', "yavorski/lualine-macro-recording.nvim" },
		opts = function()
			return {
				options = {
					globalstatus = vim.o.laststatus == 3,
					disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
					theme = "kissa",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { 'branch', 'diff', 'diagnostics' },
					lualine_c = { 'filename', 'macro_recording' },
					lualine_x = {},
					lualine_y = {},
				},
			}
		end
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = false,
			},
		}
	},
	{
		"folke/snacks.nvim",
		opts = function()
			vim.g.snacks_animate = false
			return {
				indent = { enabled = false },
				input = { enabled = true },
				picker = { enabled = true },
				words = { enabled = true },
				notifier = { enabled = true, style = "fancy" },
				scope = { enabled = true },
				statuscolumn = { enabled = true },
				scroll = { enabled = true },
			}
		end
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			dashboard = {
				sections = {
					{ section = "header" },
					{ icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
					{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
					{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
					{ section = "startup", padding = { 0, 5 } },
				},
			},
		}
	}
}
