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
                    -- "ts_ls", -- commenting this out so we can use some other faster ts lsp :)
                    "gopls",
                    "html",
                    "tailwindcss",
                    "dockerls",
                    "prismals"
                    -- haven't added solidity, but we have installed using Mason
                },
            })

            -- vim.lsp.config() is what automatic_enable uses (Neovim 0.11+)
            vim.lsp.config("*", {
                capabilities = capabilities,
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

            vim.lsp.config("tailwindcss", {
                workspace_required = true,
                filetypes = {
                    "html",
                    "css",
                    "scss",
                    "javascriptreact",
                    "typescriptreact",
                },
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
            })

            vim.lsp.config("solidity_ls_nomicfoundation", {
                root_markers = { "foundry.toml", "hardhat.config.js", ".git" },
            })

            local kind_icons = require("mecodes.icons").kind

            local cmp_select = { behavior = cmp.SelectBehavior.Select }
            local luasnip = require("luasnip")
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
                        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                    },
                    documentation = {
                        border = "rounded",
                        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                    },
                },
                mapping = cmp.mapping.preset.insert({
                    -- Scroll the documentation window [b]ack / [f]orward
                    ["<C-f>"] = cmp.mapping.scroll_docs(-8),
                    ["<C-d>"] = cmp.mapping.scroll_docs(8),

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
            "ray-x/lsp_signature.nvim"
        },
    },
    {
        "ray-x/lsp_signature.nvim",
        config = function()
            require "lsp_signature".setup()
        end
    },
}
