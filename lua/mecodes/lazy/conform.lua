local constants = require("mecodes.constants")

local JS_FORMATTERS = { "prettier", "rustywind", stop_after_first = true }

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
			jsonc = { "fixjson" },
			yaml = { "prettier" },
			toml = { "taplo" },
			markdown = { "markdownlint" },
			go = { "gofmt" },
			solidity = { "forge_fmt" },
			nginx = { "nginxfmt" },
			python = { "isort" },
			java = { "google-java-format" },

			javascript = JS_FORMATTERS,
			typescript = JS_FORMATTERS,
			javascriptreact = JS_FORMATTERS,
			typescriptreact = JS_FORMATTERS,
			css = JS_FORMATTERS,
			scss = JS_FORMATTERS,
			html = { "ast-grep", "rustywind" },

			prisma = { "prisma_fmt" },
			graphql = { "prettier" },
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
	},

	config = function(_, opts)
		require("conform").setup(opts)

		-- Keymap: format buffer or selection
		vim.keymap.set({ "n", "v" }, "<leader>cf", function()
			require("conform").format({ async = true, lsp_format = "fallback" })
			print("Formatting Successful")
		end, { desc = "Format with conform.nvim" })

		vim.keymap.set({ "n" }, "<leader>ci", function()
			vim.cmd("ConformInfo")
		end, { desc = "Format with conform.nvim" })
	end,
}
