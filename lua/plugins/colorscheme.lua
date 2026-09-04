-- local function get_tinty_scheme()
-- 	local handle = io.popen("tinty current 2>/dev/null")
-- 	if handle then
-- 		local scheme = handle:read("*a")
-- 		handle:close()
-- 		if scheme and scheme ~= "" then
-- 			return scheme:gsub("%s+", ""):gsub("\n", "")
-- 		end
-- 	end
-- 	return nil
-- end
--
-- return {
-- 	{
-- 		"f-person/auto-dark-mode.nvim",
-- 		priority = 1000,
-- 		lazy = false,
-- 		opts = {
-- 			set_dark_mode = function()
-- 				vim.api.nvim_set_option_value("background", "dark", {})
-- 				local scheme = get_tinty_scheme()
-- 				if scheme then
-- 					pcall(require("tinted-nvim").load, scheme)
-- 				end
-- 			end,
-- 			set_light_mode = function()
-- 				vim.api.nvim_set_option_value("background", "light", {})
-- 				local scheme = get_tinty_scheme()
-- 				if scheme then
-- 					pcall(require("tinted-nvim").load, scheme)
-- 				end
-- 			end,
-- 			update_interval = 5000,
-- 		},
-- 	},
-- {
-- 		"tinted-theming/tinted-nvim",
-- 		priority = 1001,
-- 		lazy = false,
-- 		opts = {
-- 			default_scheme = "base16-chicago-night",
-- 			apply_scheme_on_startup = true,
-- 		},
-- 		init = function()
-- 			local ok, tinted = pcall(require, "tinted-nvim")
-- 			if not ok then
-- 				return
-- 			end
-- 			local scheme = get_tinty_scheme()
-- 			if scheme then
-- 				tinted.load(scheme)
-- 			else
-- 				local fallback = vim.o.background == "light" and "base16-chicago-day" or "base16-chicago-night"
-- 				tinted.load(fallback)
-- 			end
-- 			vim.g.tinted_palette = tinted.get_palette()
-- 		end,
-- 	},
-- 	{
-- 		"savq/melange-nvim",
-- 		enabled = false,
-- 		lazy = false,
-- 		priority = 1000,
-- 		config = function()
-- 			vim.cmd([[colorscheme melange]])
-- 		end,
-- 	},
-- }
--

return {
	{
		"f-person/auto-dark-mode.nvim",
		lazy = false,
		priority = 1100,
		opts = {
			update_interval = 5000,
		},
	},
	{
		"rwendell/kissa",
		lazy = false,
		priority = 1000,
		config = function()
			require("kissa").setup({ variant = "auto" })
		end,
	},
}
