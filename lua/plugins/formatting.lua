return {

	{
		"stevearc/conform.nvim",
		dependencies = { "mason.nvim" },
		opts = {
			default_format_opts = {
				timeout_ms = 3000,
				async = false,
				quiet = false,
				lsp_format = "fallback",
			},
			format_on_save = {
				-- Ceiling only: fast formatters (biome) return immediately.
				-- The Svelte server can take seconds on a cold session.
				timeout_ms = 5000,
			},
			formatters_by_ft = {
				css = { "biome" },
				graphql = { "biome" },
				javascript = { "biome" },
				javascriptreact = { "biome" },
				json = { "biome" },
				jsonc = { "biome" },
				-- Note: no `svelte` entry. Biome can't format Svelte files
				-- (lint + assists only), so Svelte saves fall through to the
				-- default `lsp_format = "fallback"` above and are formatted
				-- by the Svelte language server instead.
				typescript = { "biome" },
				typescriptreact = { "biome" },
			},
			formatters = {
				biome = {
					-- Prefer the project's own biome so the editor formats
					-- with the same version as the repo's lint command.
					command = function(_, ctx)
						local found = vim.fs.find("node_modules/.bin/biome", {
							path = ctx.dirname,
							upward = true,
							type = "file",
						})[1]
						if found and vim.fn.executable(found) == 1 then
							return found
						end
						return "biome"
					end,
				},
			},
		}
	},

}
