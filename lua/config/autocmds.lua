vim.api.nvim_create_autocmd({ "BufNewFile", "BufEnter" }, {
  desc = "Prompt for filetype if not set on empty/new buffer",
  callback = function(args)
    local buf = args.buf

    -- Ignore special buftypes immediately
    if vim.bo[buf].buftype ~= "" then
      return
    end

    -- Defer the check slightly. This allows plugins like Snacks to finish 
    -- setting up their dashboard buffers before we check the filetype.
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then 
        return 
      end

      -- If Snacks (or another plugin) claimed the buffer, abort
      if vim.bo[buf].filetype ~= "" or vim.bo[buf].buftype ~= "" then
        return
      end

      -- Explicitly check Snacks variables just in case
      if vim.b[buf].snacks_dashboard or vim.api.nvim_buf_get_name(buf):match("snacks_dashboard") then
        return
      end

      -- If we made it here, it's a genuine empty/untyped buffer
      vim.ui.input({
        prompt = "Set filetype: ",
        completion = "filetype",
      }, function(input)
        if input and input ~= "" then
          vim.bo[buf].filetype = input
        end
      end)
    end)
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

--- Applies `source.*` actions (fix-all, organize imports) to a buffer.
--- Synchronous: requests, resolves if needed, applies edits. Agnostic: every
--- attached client is asked with generic `source.*` kinds, which servers
--- match against their own suffixed kinds (biome's spelled out too, given
--- its history of kind bugs). Fix-all runs on every client; organize-imports
--- runs on one client only (biome when attached, else the first offering
--- client) so two organizers never fight over the same lines.
function apply_source_actions(bufnr, opts)
	if vim.bo[bufnr].buftype ~= "" then
		return
	end
	local clients = {}
	for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		table.insert(clients, c)
	end
	if #clients == 0 then
		return
	end

	local function resolve_and_apply(client, action)
		local edit = action.edit
		if not edit and action.data then
			local resolved = client:request_sync("codeAction/resolve", action, 1000, bufnr)
			if resolved and resolved.result then
				edit = resolved.result.edit
			end
		end
		if edit then
			vim.lsp.util.apply_workspace_edit(edit, client.offset_encoding)
		end
	end

	local function base_params(only)
		return {
			textDocument = { uri = vim.uri_from_bufnr(bufnr) },
			range = {
				start = { line = 0, character = 0 },
				["end"] = { line = 0, character = 0 },
			},
			context = { only = only, diagnostics = {} },
		}
	end

	if opts.fix_all then
		local params = base_params({ "source.fixAll", "source.fixAll.biome" })
		for _, client in ipairs(clients) do
			local resp = client:request_sync("textDocument/codeAction", params, 2000, bufnr)
			if resp and resp.result then
				for _, action in ipairs(resp.result) do
					resolve_and_apply(client, action)
				end
			end
		end
	end
	if opts.organize_imports then
		local organizer = clients[1]
		for _, client in ipairs(clients) do
			if client.name == "biome" then
				organizer = client
				break
			end
		end
		local resp = organizer:request_sync(
			"textDocument/codeAction",
			base_params({ "source.organizeImports", "source.organizeImports.biome" }),
			2000,
			bufnr
		)
		if resp and resp.result then
			for _, action in ipairs(resp.result) do
				resolve_and_apply(organizer, action)
			end
		end
	end
end

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(e)
		local opts = { buffer = e.buf }
		vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
		vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
		vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
		vim.keymap.set("n", "<leader>cc", function()
			apply_source_actions(e.buf, { fix_all = true, organize_imports = true })
		end, opts)
		vim.keymap.set("n", "<leader>cr", function() vim.lsp.buf.references() end, opts)
		vim.keymap.set("n", "<leader>crn", function() vim.lsp.buf.rename() end, opts)
	end
})
