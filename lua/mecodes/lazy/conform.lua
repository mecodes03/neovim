return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettier" },
				yaml = { "prettier" },
				graphql = { "prettier" },
				markdown = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				go = { "gofmt" },
				html = { "prettier" },
				solidity = { "forge_fmt" },
				nginx = { "nginxfmt" },
			},

			formatters = {
				forge_fmt = {
					command = "forge",
					args = { "fmt", "--raw", "$FILENAME" },
					stdin = false,
				},
			},
			format_on_save = {
				lsp_format = "fallback",
				timeout_ms = 500,
			},
			vim.keymap.set({ "n", "v" }, "<leader>cf", function()
				if require("conform").format() then
					vim.notify("File formatted")
				else
					vim.notify("No formatter found")
				end
			end, { desc = "Format Current File" }),
		})
	end,
}
