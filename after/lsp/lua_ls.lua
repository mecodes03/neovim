---@type vim.lsp.Config
return {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim", "it", "describe", "before_each", "after_each" },
			},
		},
	},
}
