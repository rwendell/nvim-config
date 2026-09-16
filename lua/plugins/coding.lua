local opencode_go_key
local opencode_go_key_loaded = false

local function get_opencode_go_key()
	if opencode_go_key_loaded then
		return opencode_go_key
	end

	opencode_go_key_loaded = true
	if vim.env.OPENCODE_GO_API_KEY and vim.env.OPENCODE_GO_API_KEY ~= '' then
		opencode_go_key = vim.env.OPENCODE_GO_API_KEY
		return opencode_go_key
	end

	local auth_path = vim.fn.expand('~/.local/share/opencode/auth.json')
	local ok, lines = pcall(vim.fn.readfile, auth_path)
	if not ok then
		return nil
	end

	local decoded, auth = pcall(vim.json.decode, table.concat(lines, '\n'))
	if not decoded or type(auth) ~= 'table' then
		return nil
	end

	local account = auth['opencode-go']
	opencode_go_key = type(account) == 'table' and account.key or nil
	return opencode_go_key
end

return {
	{
		'saghen/blink.cmp',
		dependencies = {
			'rafamadriz/friendly-snippets',
			'L3MON4D3/LuaSnip',
			{
				'milanglacier/minuet-ai.nvim',
				config = function()
					require('minuet').setup {
						provider = 'openai_compatible',
						request_timeout = 2.5,
						throttle = 1500,
						debounce = 600,
						blink = { enable_auto_complete = false },
						provider_options = {
							openai_compatible = {
								api_key = get_opencode_go_key,
								end_point = 'https://opencode.ai/zen/go/v1/chat/completions',
								model = 'deepseek-v4.1-flash',
								name = 'OpenCode Go',
								optional = {
									max_tokens = 56,
									top_p = 0.9,
									thinking = { type = 'disabled' },
								},
							},
						},
					}
				end,
			},
		},
		version = '1.*',
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = function(_, opts)
			opts.snippets = vim.tbl_deep_extend('force', { preset = 'luasnip' }, opts.snippets or {})
			opts.keymap = vim.tbl_deep_extend('force', { preset = 'default' }, opts.keymap or {}, {
				['<A-y>'] = require('minuet').make_blink_map(),
			})
			opts.appearance = vim.tbl_deep_extend('force', { nerd_font_variant = 'mono' }, opts.appearance or {})
			opts.sources = opts.sources or {}
			opts.sources.default = vim.list_extend(opts.sources.default or { 'lsp', 'path', 'snippets', 'buffer' }, { 'minuet' })
			opts.sources.providers = vim.tbl_deep_extend('force', opts.sources.providers or {}, {
				minuet = {
					name = 'minuet',
					module = 'minuet.blink',
					async = true,
					timeout_ms = 3000,
					score_offset = 50,
				},
			})
			opts.completion = vim.tbl_deep_extend('force', {
				documentation = { auto_show = false },
				trigger = { prefetch_on_insert = false },
			}, opts.completion or {})
			opts.fuzzy = vim.tbl_deep_extend('force', { implementation = 'prefer_rust_with_warning' }, opts.fuzzy or {})
			return opts
		end,
		-- (Default) Only show the documentation popup when manually triggered
		opts_extend = { 'sources.default' },
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
