return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			vim.lsp.config("svelte", {
				settings = {
					svelte = {
						plugins = {
							svelteIgnore = { enable = true },
						},
					},
				},
			})
		end,
	},
}
