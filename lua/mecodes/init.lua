require("mecodes.set")
require("mecodes.remap")
require("mecodes.lazy_init")
require("mecodes.transparency")
require("mecodes.icons")
require("mecodes.constants")

local augroup = vim.api.nvim_create_augroup
local MecodesGroup = augroup("mecodes", {})

local autocmd = vim.api.nvim_create_autocmd

local yank_group = augroup("HighlightYank", {})
local cd_to_arg_dir_group = augroup("cd-to-pwd", { clear = true })
local buf_enter_group = augroup("buf_enter", { clear = true })

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        templ = "templ",
    },
})

autocmd("TextYankPost", {
    group = yank_group,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 80,
        })
    end,
})

autocmd({ "BufWritePre" }, {
    group = MecodesGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd("BufEnter", {
    group = buf_enter_group,
    callback = function()
        -- TODO: on entering buffer, check dir.. if it is a subdirectory of the project dir.. then do nothing, if it is a parent dir of project dir, make that one the project dir, always keep record of original project dir.. so incase we come back to it or come one level closer to it, we'll make that one the project dir. ( I dont' know how we can do this tho:) )
    end
})

autocmd("VimEnter", {
    group = cd_to_arg_dir_group,
    callback = function()
        if vim.fn.argc() > 0 then
            local file = vim.fn.argv(0)
            if file ~= "" then
                local dir = vim.fn.fnamemodify(file, ":p:h")
                vim.cmd("cd " .. dir)
            end
        end
    end,
    desc = "cd to passed $PWD when vim starts.",
})

autocmd("LspAttach", {
    group = MecodesGroup,
    callback = function(e)
        local opts = { buffer = e.buf, silent = true }
        vim.keymap.set("n", "gd", function()
            vim.lsp.buf.definition()
        end, opts)
        vim.keymap.set("n", "gD", function()
            vim.lsp.buf.declaration()
        end, opts)
        vim.keymap.set("n", "gi", function()
            vim.lsp.buf.implementation()
        end, opts)
        vim.keymap.set("n", "gt", function()
            vim.lsp.buf.type_definition()
        end, opts)
        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ border = "rounded", max_height = 25, max_width = 90 })
        end, opts)
        vim.keymap.set("n", "<leader>ws", function()
            vim.lsp.buf.workspace_symbol()
        end, opts)
        vim.keymap.set("n", "<leader>d", function()
            vim.diagnostic.open_float()
        end, opts)
        vim.keymap.set("n", "<leader>ca", function()
            vim.lsp.buf.code_action()
        end, opts)
        vim.keymap.set("n", "<leader>gr", function()
            vim.lsp.buf.references()
        end, opts)
        vim.keymap.set("n", "<leader>rn", function()
            vim.lsp.buf.rename()
        end, opts)
        vim.keymap.set("i", "<C-h>", function()
            vim.lsp.buf.signature_help()
        end, opts)
        vim.keymap.set("n", "<leader>en", function()
            vim.diagnostic.goto_next()
        end, opts)
        vim.keymap.set("n", "<leader>ep", function()
            vim.diagnostic.goto_prev()
        end, opts)
        vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<cr>", opts)
        vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<cr>", opts)
        vim.keymap.set("n", "<leader>lh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = e.buf }), { bufnr = e.buf })
        end, opts)


        local client = vim.lsp.get_client_by_id(e.data.client_id)
        if not client then return end

        -- Document highlight on cursor hold
        if client.server_capabilities.documentHighlightProvider then
            local group = vim.api.nvim_create_augroup("LspDocumentHighlight_" .. e.buf, { clear = true })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = e.buf,
                group = group,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = e.buf,
                group = group,
                callback = vim.lsp.buf.clear_references,
            })
        end
    end,
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
