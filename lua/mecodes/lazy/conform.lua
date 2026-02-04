local constants = require("mecodes.constants")

local JS_FORMATTERS = { "prettier", "rustywind" }

return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	init = function()
		vim.o.formatexpr = [[v:lua.require'conform'.formatexpr()]]
	end,
	opts = {
		formatters_by_ft = {
			["_"] = { "trim_whitespace" },
			lua = { "stylua" },
			rust = { "rustfmt", lsp_format = "fallback" },
			json = { "fixjson" },
			yaml = { "prettier" },
			toml = { "taplo" },
			markdown = { "markdownlint" },
			go = { "gofmt" },
			solidity = { "forge_fmt" },
			nginx = { "nginxfmt" },
			python = { "isort" },
			javascript = JS_FORMATTERS,
			typescript = JS_FORMATTERS,
			javascriptreact = JS_FORMATTERS,
			typescriptreact = JS_FORMATTERS,
			css = JS_FORMATTERS,
			scss = JS_FORMATTERS,
			html = JS_FORMATTERS,

			prisma = { "prisma_fmt" }
		},

		formatters = {
			forge_fmt = {
				command = "forge",
				args = { "fmt", "--raw", "$filename" },
				stdin = false,
			},

			prisma_fmt = {
				command = "bunx ",
				args = { "prisma", "format" },
				stdin = false,
			},

			prettier = {
				prepend_args = {
					"--tab-width",
					constants.TAB_WIDTH,
					"--indent-width",
					constants.INDENT_SIZE,
				},
			},

			prettierd = {
				prepend_args = {
					"--tab-width",
					constants.TAB_WIDTH,
					"--indent-width",
					constants.INDENT_SIZE,
				},
			},
		},

		format_on_save = function(bufnr)
			local ignore_filetypes = { "svg" }
			if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
				return
			end
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			if bufname:match("/node_modules/") then
				return
			end
			return { timeout_ms = 500, lsp_fallback = true }
		end,
	},

	config = function(_, opts)
		require("conform").setup(opts)

		-- Keymap: format buffer or selection
		vim.keymap.set({ "n", "v" }, "<leader>cf", function()
			require("conform").format({ async = true, lsp_fallback = true })
			print("Formatting Successful")
		end, { desc = "Format with conform.nvim" })
	end,
}
