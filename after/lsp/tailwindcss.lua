---@type vim.lsp.Config
return {
	filetypes = {
		"html",
		"css",
		"scss",
		"javascriptreact",
		"typescriptreact",
	},
	workspace_required = true,
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		-- Lockfiles only exist at the workspace root, never in sub-packages.
		-- This ensures a single LSP instance per monorepo.
		local lockfile = vim.fs.find({
			"pnpm-lock.yaml",
			"pnpm-workspace.yaml",
			"yarn.lock",
			"bun.lockb",
			"bun.lock",
			"package-lock.json",
		}, { path = fname, upward = true })[1]

		if lockfile then
			return on_dir(vim.fs.dirname(lockfile))
		end

		-- Fallback for non-monorepo projects
		local config_file = vim.fs.find({
			"tailwind.config.js",
			"tailwind.config.ts",
			"tailwind.config.mjs",
			"tailwind.config.cjs",
			"postcss.config.js",
			"postcss.config.mjs",
			"postcss.config.ts",
			"postcss.config.cjs",
		}, { path = fname, upward = true })[1]

		if config_file then
			return on_dir(vim.fs.dirname(config_file))
		end
	end,
}
