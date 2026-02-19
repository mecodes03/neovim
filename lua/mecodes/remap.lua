vim.g.mapleader = " "
-- open explorer
vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Open netrw explorer" })

-- move lines (select visualy and then move up and down)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- delete line space or something like than and yet have cursor in start
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines, keep cursor position" })

-- up and down
vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set({ "n", "v" }, "<C-f>", "<C-u>zz", { desc = "Scroll up and center" })

-- find and center (corsor stays in center)
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search result centered" })

-- paste and still have the copied into clipboard
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- copy into sys clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

local opts = { noremap = true, silent = true }

-- save file
vim.keymap.set("n", "<C-s>", "<cmd> w <CR>", { noremap = true, silent = true, desc = "Save file" })

-- quit file
vim.keymap.set("n", "<C-x>", "<cmd> q <CR>", { noremap = true, silent = true, desc = "Quit file" })

-- delete buffer
vim.keymap.set("n", "<leader>x", "<cmd>bdelete<CR>", { silent = true, desc = "Delete buffer" })

-- delete single character without copying into register
vim.keymap.set("n", "x", '"_x', { noremap = true, silent = true, desc = "Delete char without yank" })

-- Toggle line wrapping
vim.keymap.set("n", "<leader>lw", "<cmd>set wrap!<CR>", { noremap = true, silent = true, desc = "Toggle line wrap" })

-- Better indenting (stay in visual mode)
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Select all
vim.keymap.set("n", "<leader>sa", "ggVG", { desc = "Select all" })

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- format
-- vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- back to normal mode
vim.keymap.set("n", "<C-c>", "<Esc>", { noremap = true, silent = true })

-- rename current word
vim.keymap.set("n", "<leader>rr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Search/replace word under cursor" })

-- make file executable
vim.keymap.set("n", "<leader>X", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- Resize with arrows
vim.keymap.set("n", "<Up>", ":resize -1<CR>", opts)
vim.keymap.set("n", "<Down>", ":resize +1<CR>", opts)
vim.keymap.set("n", "<Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<Right>", ":vertical resize +2<CR>", opts)

-- Buffers
vim.keymap.set("n", "<Tab>", ":bnext<CR>", opts)
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", opts)

-- moving
vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>zz", { desc = "prev/next in Quickfix List" })
vim.keymap.set("n", "<C-k>", "<cmd>cprev<CR>zz", { desc = "prev/next in Quickfix List" })
vim.keymap.set("n", "<leader>j", "<cmd>lnext<CR>zz", { desc = "prev/next in Location List" })
vim.keymap.set("n", "<leader>k", "<cmd>lprev<CR>zz", { desc = "prev/next in Location List" })

-- commenting lines
vim.keymap.set("v", "<leader>/", function()
	local count = vim.v.count
	vim.cmd.norm((count > 0 and count or "") .. "gcc")
end, { desc = "Toggle Comment" })

vim.keymap.set("n", "<leader>/", function()
	local count = vim.v.count
	if count > 0 then
		count = count + 1 -- Include the current line
	end
	vim.cmd.norm((count > 0 and count or "") .. "gcc")
end, { desc = "Toggle Comment" })

vim.keymap.set("o", "<leader>/", function()
	local count = vim.v.count
	vim.cmd.norm((count > 0 and count or "") .. "gcc")
end, { desc = "Toggle Comment" })

vim.keymap.set("x", "<leader>/", function()
	local count = vim.v.count
	vim.cmd.norm((count > 0 and count or "") .. "gcc")
end, { desc = "Toggle Comment" })

vim.keymap.set("n", "<leader>la", "<cmd>Lazy<cr>", { desc = "Lazy plugin manager" })

-- mouse toggle
vim.keymap.set("n", "<leader>tm", function()
	if vim.o.mouse == "" then
		vim.o.mouse = "a"
		print("Mouse Enable")
	else
		vim.o.mouse = ""
		print("Mouse Disable")
	end
end, { desc = "Toggle Mouse" })

-- toggle Transparency
vim.keymap.set("n", "<leader>tr", ":lua ToggleTransparency()<CR>", { desc = "Toggle Transparency" })

-- unhighlight
vim.keymap.set("n", "<leader>rh", ":noh<CR>", { silent = true, desc = "unhighlight" })

-- toggle cursorline
vim.keymap.set("n", "<leader>tl", function()
		-- enable if not enabled
		if not vim.o.cursorline then
			vim.o.cursorline = true
		end

		if vim.o.cursorlineopt == "number" then
			vim.o.cursorlineopt = "both"
		elseif vim.o.cursorlineopt == "both" then
			vim.o.cursorlineopt = "number"
		end
	end,
	{ silent = true, desc = "Toggle Cursorline" }
)
