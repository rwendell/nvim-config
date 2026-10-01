return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- Enable biome explicitly so it attaches via the project's
			-- own node_modules/.bin/biome even before Mason's copy exists.
			vim.lsp.enable("biome")
			local symbols = { Error = "󰅙", Info = "󰋼", Hint = "󰌵", Warn = "" }
			for name, icon in pairs(symbols) do
				local hl = "DiagnosticSign" .. name
				vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
			end
			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
			})
		end
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = { ensure_installed = { "svelte", "biome" } },
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
	},
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		build = ":MasonUpdate",
		opts_extend = { "ensure_installed" },
		opts = {},
	}
}
