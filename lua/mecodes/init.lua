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
	end,
})

autocmd("VimEnter", {
	group = cd_to_arg_dir_group,
	callback = function()
		local cwd = vim.fn.getcwd()
		-- print(cwd)

		-- load obsidian if in vault directory
		if cwd:find("/home/mecodes/vault") then
			require("lazy").load({ plugins = { "obsidian.nvim" } })
			print("obsidian loaded")
		end

		-- cd to file's directory if file passed as argument
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

local cmd = vim.cmd
local lsp = vim.lsp
local bo = vim.bo

autocmd("LspAttach", {
	group = MecodesGroup,
	callback = function(args)
		vim.keymap.set("n", "gd", function()
			vim.lsp.buf.definition()
		end, { buffer = args.buf, silent = true, desc = "Go to Definition" })

		vim.keymap.set("n", "gD", function()
			vim.lsp.buf.declaration()
		end, { buffer = args.buf, silent = true, desc = "Go to Declaration" })

		vim.keymap.set("n", "gi", function()
			vim.lsp.buf.implementation()
		end, { buffer = args.buf, silent = true, desc = "Go To Implementation" })

		vim.keymap.set("n", "gt", function()
			vim.lsp.buf.type_definition()
		end, { buffer = args.buf, silent = true, desc = "Go to Type Definition" })

		vim.keymap.set("n", "grr", function()
			vim.lsp.buf.references()
		end, { buffer = args.buf, silent = true, desc = "List References Under Cursor" })

		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover({ border = "rounded", max_height = 25, max_width = 90 })
		end, { buffer = args.buf, silent = true, desc = "Hover" })

		vim.keymap.set("n", "<leader>ws", function()
			vim.lsp.buf.workspace_symbol()
		end, { buffer = args.buf, silent = true, desc = "List Document Symbols" })

		vim.keymap.set("n", "<leader>ca", function()
			vim.lsp.buf.code_action()
		end, { buffer = args.buf, silent = true, desc = "Code Action" })

		vim.keymap.set("n", "grn", function()
			vim.lsp.buf.rename()
		end, { buffer = args.buf, silent = true, desc = "Rename Buffer" })

		vim.keymap.set("i", "<C-s>", function()
			vim.lsp.buf.signature_help({ border = "rounded", max_height = 25, max_width = 90 })
		end, { buffer = args.buf, silent = true, desc = "Signature Help Under Cursor" })

		vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<cr>", { buffer = args.buf, silent = true })
		vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<cr>", { buffer = args.buf, silent = true })
		vim.keymap.set("n", "<leader>ih", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
		end, { buffer = args.buf, silent = true, desc = "Inlay Hint Toggle" })

		local client = vim.lsp.get_clients({ id = args.data.client_id })[1]
		if not client then
			return
		end

		-- Document highlight on cursor hold
		if client.server_capabilities.documentHighlightProvider then
			local group = vim.api.nvim_create_augroup("LspDocumentHighlight_" .. args.buf, { clear = true })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = args.buf,
				group = group,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = args.buf,
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

		local function is_large(buf)
			local max_filesize = 100 * 1024 -- 100 KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			else
				return false
			end
		end

		-- Disable LSP for files larger than 100KB.
		if is_large(0) then
			print("(LSP) DISABLED, file too large")
			cmd([[lsp stop]])
			return
		end

		-- Disable LSP formatting for certain Language Servers where Conform, running a command line
		-- formatter, will instead be used.
		if
			client.name == "cssls"
			or client.name == "eslint"
			or client.name == "html"
			or client.name == "ruby_lsp"
			or client.name == "ts_ls"
			or client.name == "tailwindcss"
		then
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
		end

		-- Enable virtual text document color for supported language servers.
		if client:supports_method("textDocument/documentColor") and vim.lsp.document_color then
			lsp.document_color.enable(true, { bufnr = 0 }, { style = "▮ " })
		end

		-- Tailwind LSP trigger characters are annoying, disable them.
		--
		-- Note, to list current trigger characters run this command:
		--   :lua print(vim.inspect(vim.lsp.buf_get_clients()[1].server_capabilities.completionProvider.triggerCharacters))
		if client.name == "tailwindcss" then
			client.server_capabilities.completionProvider.triggerCharacters = {}
		end
	end,
})
