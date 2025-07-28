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
				ensure_installed = {
					"lua_ls",
					"rust_analyzer",
					-- "ts_ls", -- commenting this out so we can use some other faster ts lsp :)
					"gopls",
					"html",
					"tailwindcss",
					"dockerls",
					-- haven't added solidity, but we have installed using Mason
				},

				handlers = {
					function(server_name) -- default handler (optional)
						require("lspconfig")[server_name].setup({
							capabilities = capabilities,
						})
					end,

					["lua_ls"] = function()
						local lspconfig = require("lspconfig")
						lspconfig.lua_ls.setup({
							capabilities = capabilities,
							settings = {
								Lua = {
									diagnostics = {
										globals = { "vim", "it", "describe", "before_each", "after_each" },
									},
								},
							},
						})
					end,

					-- ["ts_ls"] = function()
					-- 	local lspconfig = require("lspconfig")
					-- 	local util = require("lspconfig.util")
					-- 	lspconfig.ts_ls.setup({
					-- 		capabilities = capabilities,
					-- 		root_dir = util.root_pattern(".git"), -- You can adjust as needed
					-- 	})
					-- end,

					["solidity_ls_nomicfoundation"] = function()
						local lspconfig = require("lspconfig")
						local util = require("lspconfig.util")
						lspconfig.solidity_ls_nomicfoundation.setup({
							capabilities = capabilities,
							-- on_attach =
							root_dir = util.root_pattern("foundry.toml", ".git", "hardhat.config.js"), -- You can adjust as needed
						})
					end,
					--
					-- ["solidity_ls"] = function()
					-- 	local lspconfig = require("lspconfig")
					-- 	lspconfig.solidity_ls.setup({
					-- 		cmd = { "vscode-solidity-server", "--stdio" },
					-- 		filetypes = { "solidity" },
					-- 		root_dir = lspconfig.util.root_pattern("hardhat.config.js", "foundry.toml", ".git"),
					-- 		settings = {
					-- 			solidity = {
					-- 				compileUsingRemoteVersion = "latest",
					-- 				defaultCompiler = "remote",
					-- 				enabledAsYouTypeCompilationErrorCheck = true,
					-- 				packageDefaultDependenciesContractsDirectory = "src",
					-- 				packageDefaultDependenciesDirectory = "lib",
					-- 			},
					-- 		},
					-- 	})
					-- end,

					-- commenting out cos I think the default function will take care of it
					-- ["html"] = function()
					-- 	local lspconfig = require("lspconfig")
					-- 	lspconfig.html.setup({
					-- 		capabilities = capabilities,
					-- 		filetypes = { "html", "tsx", "jsx" },
					-- 	})
					-- end,
				},
			})

			local kind_icons = {
				Text = "󰉿",
				Method = "m",
				Function = "󰊕",
				Constructor = "",
				Field = "",
				Variable = "󰆧",
				Class = "󰌗",
				Interface = "",
				Module = "",
				Property = "",
				Unit = "",
				Value = "󰎠",
				Enum = "",
				Keyword = "󰌋",
				Snippet = "",
				Color = "󰏘",
				File = "󰈙",
				Reference = "",
				Folder = "󰉋",
				EnumMember = "",
				Constant = "󰇽",
				Struct = "",
				Event = "",
				Operator = "󰆕",
				TypeParameter = "󰊄",
			}

			local cmp_select = { behavior = cmp.SelectBehavior.Select }
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body) -- For `luasnip` users.
					end,
				},
				window = {
					-- documentation = cmp.config.window.bordered(),
					-- completion = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					-- Scroll the documentation window [b]ack / [f]orward
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					-- <c-l> will move you to the right of each of the expansion locations.
					-- <c-h> is similar, except moving you backwards.
					-- ["<C-l>"] = cmp.mapping(function()
					-- 	if luasnip.expand_or_locally_jumpable() then
					-- 		luasnip.expand_or_jump()
					-- 	end
					-- end, { "i", "s" }),
					-- ["<C-h>"] = cmp.mapping(function()
					-- 	if luasnip.locally_jumpable(-1) then
					-- 		luasnip.jump(-1)
					-- 	end
					-- end, { "i", "s" }),

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
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
						})[entry.source.name]
						return vim_item
					end,
				},
			})

			vim.diagnostic.config({
				-- update_in_insert = true,
				float = {
					focusable = false,
					style = "minimal",
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
				},
			})
		end,
	},
	-- I think we can move the below stuff into our handlers above, just like we have done for lua_ls
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		config = function()
			local api = require("typescript-tools.api")
			require("typescript-tools").setup({
				handlers = {
					["textDocument/publishDiagnostics"] = api.filter_diagnostics(
						-- Ignore 'This may be converted to an async function' diagnostics.
						{ 80006 }
					),
				},
			})
		end,
	},
}
