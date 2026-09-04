return {
	{
		"xvzc/chezmoi.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		lazy = false,
		config = function()
			require("chezmoi").setup({})
		end,
	},
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {}
	},
	{
		"folke/snacks.nvim",
		opts = {
			bigfile = { enabled = true },
			quickfile = { enabled = true },
			terminal = { enabled = false },

		}
	},
	{
		"echasnovski/mini.hipatterns",
		opts = function()
			local hi = require("mini.hipatterns")
			return {
				highlighters = { hex_color = hi.gen_highlighter.hex_color(), },
			}
		end,
		config = function(_, opts)
			require("mini.hipatterns").setup(opts)
		end,
	}
}
