require("mecodes.icons")
require("mecodes.constants")
require("mecodes.remap")
require("mecodes.lazy_init")
require("mecodes.set")

local augroup = vim.api.nvim_create_augroup
local MecodesGroup = augroup("mecodes", { clear = true })

local autocmd = vim.api.nvim_create_autocmd

local yank_group = augroup("HighlightYank", { clear = true })
local cd_to_arg_dir_group = augroup("cd-to-pwd", { clear = true })
local buf_enter_group = augroup("buf_enter", { clear = true })
local jdtls_group = augroup("jdtls_lsp", { clear = true })

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
        vim.hl.on_yank({
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
                vim.fn.chdir(dir)
            end
        end
    end,
    desc = "cd to passed $PWD when vim starts.",
})

-- Setup our JDTLS server any time we open up a java file
autocmd("FileType", {
    group = jdtls_group,
    pattern = "java",
    callback = function()
        require("mecodes.jdtls").setup_jdtls()
    end,
})

autocmd("LspAttach", {
    group = MecodesGroup,
    callback = function(e)
        vim.keymap.set("n", "gd", function()
            vim.lsp.buf.definition()
        end, { buffer = e.buf, silent = true, desc = "Go to Definition" })

        vim.keymap.set("n", "gD", function()
            vim.lsp.buf.declaration()
        end, { buffer = e.buf, silent = true }, { desc = "Go to Declaration" })

        vim.keymap.set("n", "gi", function()
            vim.lsp.buf.implementation()
        end, { buffer = e.buf, silent = true, desc = "Go To Implementation" })

        vim.keymap.set("n", "gt", function()
            vim.lsp.buf.type_definition()
        end, { buffer = e.buf, silent = true, desc = "Go to Type Definition" })

        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ border = "rounded", max_height = 25, max_width = 90 })
        end, { buffer = e.buf, silent = true, desc = "Hover" })

        vim.keymap.set("n", "<leader>ws", function()
            vim.lsp.buf.workspace_symbol()
        end, { buffer = e.buf, silent = true, desc = "List Document Symbols" })

        vim.keymap.set("n", "<leader>d", function()
            vim.diagnostic.open_float({ max_height = 25, max_width = 90 })
        end, { buffer = e.buf, silent = true, desc = "Open Diagnostic Float" })

        vim.keymap.set("n", "<leader>ca", function()
            vim.lsp.buf.code_action()
        end, { buffer = e.buf, silent = true, desc = "Code Action" })

        vim.keymap.set("n", "<leader>gr", function()
            vim.lsp.buf.references()
        end, { buffer = e.buf, silent = true, desc = "List References Under Cursor" })

        vim.keymap.set("n", "<leader>rn", function()
            vim.lsp.buf.rename()
        end, { buffer = e.buf, silent = true, desc = "Rename Buffer" })

        vim.keymap.set("i", "<C-h>", function()
            vim.lsp.buf.signature_help()
        end, { buffer = e.buf, silent = true, desc = "Signature Help Under Cursor" })

        vim.keymap.set("n", "<leader>[d", function()
            vim.diagnostic.jump({ count = 1 })
        end, { buffer = e.buf, silent = true, desc = "Next Diagnostic" })

        vim.keymap.set("n", "<leader>]d", function()
            vim.diagnostic.jump({ count = -1 })
        end, { buffer = e.buf, silent = true, desc = "Prev Diagnostic" })

        vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<cr>", { buffer = e.buf, silent = true })
        vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<cr>", { buffer = e.buf, silent = true })
        vim.keymap.set("n", "<leader>lh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = e.buf }), { bufnr = e.buf })
        end, { buffer = e.buf, silent = true, desc = "Inlay Hint Toggle" })

        local client = vim.lsp.get_clients({ id = e.data.client_id })[1]
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

        local orig = vim.lsp.util.convert_input_to_markdown_lines

        -- remove ugly urls
        vim.lsp.util.convert_input_to_markdown_lines = function(input, ...)
            local lines = orig(input, ...)

            for i, line in ipairs(lines) do
                -- remove raw jdt:// links
                lines[i] = line:gsub("%(jdt://[^%)]+%)", "")
            end

            return lines
        end
    end,
})
