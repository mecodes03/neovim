return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"j-hui/fidget.nvim",

			-- for autocompletions
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/nvim-cmp",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},

		config = function()
			local cmp = require("cmp")
			local cmp_lsp = require("cmp_nvim_lsp")

			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				cmp_lsp.default_capabilities()
			)

			require("fidget").setup({})
			require("mason").setup()
			require("mason-lspconfig").setup({
				-- jdtls is handled separately by mecodes/jdtls.lua via FileType autocmd
				automatic_enable = { exclude = { "jdtls" } },
				ensure_installed = {
					"lua_ls",
					"rust_analyzer",
					"gopls",
					-- "ts_ls", -- commenting this out so we can use some other faster ts lsp :)
					"tsgo",
					"html",
					"tailwindcss",
					-- haven't added solidity, but we have installed using Mason
				},
			})

			------------------------------------
			-- Configure the Language Servers --
			------------------------------------

			-- Notify language servers about the LSP capabilities that Neovim supports.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			-- Disable client-side watch-files for now, it is slow (see Neovim #23291).
			-- Remove this workaround when #23291 is resolved.
			capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

			-- vim.lsp.config() is what automatic_enable uses (Neovim 0.11+)
			vim.lsp.config("*", {
				capabilities = capabilities,
				flags = { debounce_text_changes = 300 },
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim", "it", "describe", "before_each", "after_each" },
						},
					},
				},
			})
			local nvim_lsp = require("lspconfig")
			local buf_get_name = vim.api.nvim_buf_get_name

			vim.lsp.config("tailwindcss", {
				filetypes = {
					"html",
					"css",
					"scss",
					"javascriptreact",
					"typescriptreact",
				},
				root_dir = function(bufnr, on_dir)
					on_dir(nvim_lsp.util.root_pattern("bun.lock")(buf_get_name(bufnr)))
				end,
			})

			local function translate_ts_diagnostic_message(message, code)
				local ok, translator = pcall(require, "ts-error-translator")
				if not ok then
					return message
				end

				local message_with_code = code and ("TS" .. tostring(code) .. ": " .. message) or message
				local parsed = translator.parse_errors(message_with_code)
				if #parsed > 0 and parsed[1].improvedError then
					return parsed[1].improvedError.body
				end

				return message
			end

			local function translate_tsgo_pull_diagnostics(err, result, ctx, config)
				if result and result.items then
					for _, diagnostic in ipairs(result.items) do
						if diagnostic.message then
							diagnostic.message = translate_ts_diagnostic_message(diagnostic.message, diagnostic.code)
						end
					end
				end

				vim.lsp.diagnostic.on_diagnostic(err, result, ctx, config)
			end

			vim.lsp.config("tsgo", {
				handlers = {
					["textDocument/diagnostic"] = translate_tsgo_pull_diagnostics,
				},
			})
			vim.lsp.config("jsonls", {
				settings = {
					json = {
						validate = { enable = true },
						format = { enable = false },
					},
				},
				handlers = {
					["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
						-- jsonls reports JSONC trailing commas/comments as parser diagnostics
						-- (codes 519/521). Keep schema diagnostics, but drop these false positives.
						if result and result.diagnostics then
							local bufnr = vim.uri_to_bufnr(result.uri)
							if vim.bo[bufnr].filetype == "jsonc" then
								result.diagnostics = vim.tbl_filter(function(diagnostic)
									local code = tostring(diagnostic.code or "")
									return code ~= "519" and code ~= "521"
								end, result.diagnostics)
							end
						end

						vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
					end,
					["textDocument/diagnostic"] = function(err, result, ctx, config)
						-- Nvim 0.12 uses LSP pull diagnostics for jsonls, so filter there too.
						if result and result.items and ctx.bufnr and vim.bo[ctx.bufnr].filetype == "jsonc" then
							result.items = vim.tbl_filter(function(diagnostic)
								local code = tostring(diagnostic.code or "")
								return code ~= "519" and code ~= "521"
							end, result.items)
						end

						vim.lsp.diagnostic.on_diagnostic(err, result, ctx, config)
					end,
				},
			})

			vim.lsp.config("solidity_ls_nomicfoundation", {
				root_markers = { "foundry.toml", "hardhat.config.js", ".git" },
			})

			local cmp_select = { behavior = cmp.SelectBehavior.Select }
			local luasnip = require("luasnip")
			local kind_icons = require("mecodes.icons").kind

			local ELLIPSIS_CHAR = "…"
			local MAX_LABEL_WIDTH = 35
			local MIN_LABEL_WIDTH = 15
			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body) -- For `luasnip` users.
					end,
				},
				window = {
					-- explicitly set border + winhighlight (bordered() alone doesn't work, see nvim-cmp#2042)
					completion = {
						border = "rounded",
						-- winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
					},
					documentation = {
						border = "rounded",
						-- winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
					},
				},

				mapping = cmp.mapping.preset.insert({
					-- Scroll the documentation window [b]ack / [f]orward
					["<C-f>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),

					-- Accept ([y]es) the completion.
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete(),

					-- Select next/previous item with Tab / Shift + Tab
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item(cmp_select)
						elseif luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item(cmp_select)
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),

					-- abort
					["<C-e>"] = cmp.mapping.abort(),
				}),

				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" }, -- For luasnip users.
					{ name = "buffer" },
					{ name = "path" },
				}),

				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
						vim_item.menu = ({
							nvim_lsp = "[L]",
							luasnip = "[S]",
							buffer = "[B]",
							path = "[P]",
						})[entry.source.name]
						local label = vim_item.abbr
						local truncated_label = vim.fn.strcharpart(label, 0, MAX_LABEL_WIDTH)
						if truncated_label ~= label then
							vim_item.abbr = truncated_label .. ELLIPSIS_CHAR
						elseif string.len(label) < MIN_LABEL_WIDTH then
							local padding = string.rep(" ", MIN_LABEL_WIDTH - string.len(label))
							vim_item.abbr = label .. padding
						end
						return vim_item
					end,
				},
			})

			vim.diagnostic.config({
				virtual_text = {
					spacing = 2,
					prefix = "●",
				},
				float = {
					border = "rounded",
					source = "if_many",
					header = "Diagnostics",
					focusable = true,
				},
				update_in_insert = false,
				severity_sort = true,
			})
		end,
	},

	{
		"mfussenegger/nvim-jdtls",
		ft = "java",
		dependencies = {
			"mfussenegger/nvim-dap",
			"ray-x/lsp_signature.nvim",
		},
	},
	-- {
	-- 	"ray-x/lsp_signature.nvim",
	-- 	event = "InsertEnter",
	-- 	opts = {
	-- 		bind = true,
	-- 		handler_opts = { border = "rounded" },
	-- 		floating_window = false,
	-- 		max_width = 80,
	-- 	},
	-- },
}
