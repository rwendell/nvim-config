return {
	{
		'saghen/blink.cmp',
		dependencies = { 'rafamadriz/friendly-snippets', 'L3MON4D3/LuaSnip' },
		version = '1.*',
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			snippets = { preset = 'luasnip' },
			keymap = { preset = 'default' },
			appearance = {
				nerd_font_variant = 'mono'
			},
			-- (Default) Only show the documentation popup when manually triggered
			completion = { documentation = { auto_show = false } },
			sources = {
				default = { 'lsp', 'path', 'snippets', 'buffer' },
			},
			fuzzy = { implementation = "prefer_rust_with_warning" }
		},
		opts_extend = { "sources.default" }
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "LazyVim",            words = { "LazyVim" } },
				{ path = "snacks.nvim",        words = { "Snacks" } },
				{ path = "lazy.nvim",          words = { "LazyVim" } },
			},
		},
	},
	{ 'echasnovski/mini.ai',       version = false,    opts = {} },
	{ 'echasnovski/mini.pairs',    version = false,    opts = {} },
	{ 'echasnovski/mini.surround', version = false,    opts = {} },
	{ "folke/ts-comments.nvim",    event = "VeryLazy", opts = {}, }

}
