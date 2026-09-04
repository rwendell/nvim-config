return {
	{
		"b0o/SchemaStore.nvim",
		lazy = true,
		version = false, -- last release is way too old
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "b0o/SchemaStore.nvim" },
		opts = function()
			local schemas = {}
			local ok, schemastore = pcall(require, "schemastore")
			if ok then
				schemas = schemastore.yaml.schemas()
			end

			vim.lsp.config("yamlls", {
				-- Have to add this for yamlls to understand that we support line folding
				capabilities = {
					textDocument = {
						foldingRange = {
							dynamicRegistration = false,
							lineFoldingOnly = true,
						},
					},
				},
				settings = {
					redhat = { telemetry = { enabled = false } },
					yaml = {
						keyOrdering = false,
						format = {
							enable = true,
						},
						validate = true,
						schemaStore = {
							-- Must disable built-in schemaStore support to use
							-- schemas from SchemaStore.nvim plugin
							enable = false,
							-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
							url = "",
						},
						schemas = schemas,
					},
				},
			})
			return {}
		end,
	}
}
