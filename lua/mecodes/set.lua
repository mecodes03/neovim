local constants = require("mecodes.constants")

local o = vim.opt
local options = {
	nu = true,                               -- show absolute line number on current line
	relativenumber = true,                   -- show relative line numbers for other lines
	tabstop = constants.INDENT_SIZE,         -- number of spaces a tab character displays as
	softtabstop = constants.TAB_WIDTH,       -- number of spaces inserted when pressing tab
	shiftwidth = constants.INDENT_SIZE,      -- number of spaces used for each indentation level
	expandtab = true,                        -- convert tabs to spaces
	smartindent = true,                      -- auto-indent new lines based on syntax
	smartcase = true,                        -- case-sensitive search only when uppercase is used
	cursorline = true,                       -- enable cursor line (needed for cursorlineopt)
	cursorlineopt = "number",                -- only highlight the line number, not the whole line
	grepprg = "rg --vimgrep --smart-case",   -- use ripgrep for :grep
	ignorecase = true,                       -- ignore case in search patterns
	wrap = false,                            -- don't wrap long lines
	swapfile = false,                        -- don't create .swp recovery files
	backup = false,                          -- don't create backup~ files
	undodir = os.getenv("HOME") .. "/.vim/undodir", -- persistent undo directory
	undofile = true,                         -- save undo history to file (survives restart)
	hlsearch = true,                         -- don't keep search matches highlighted after search
	incsearch = true,                        -- show matches as you type the search pattern
	termguicolors = true,                    -- enable 24-bit RGB colors in terminal
	scrolloff = 8,                           -- keep 8 lines visible above/below cursor when scrolling
	signcolumn = "yes",                      -- always show sign column (prevents layout shift)
	updatetime = 50,                         -- ms before CursorHold fires (affects LSP highlights, etc.)
	mouse = "",                              -- disable mouse
	colorcolumn = "80",                      -- show vertical line at column 80
	splitbelow = true,                       -- horizontal splits open below
	splitright = true,                       -- vertical splits open to the right
	inccommand = "split",                    -- live preview of :s/ substitutions in a split
	fillchars = "eob: ",                     -- hide ~ at end of buffer
	timeoutlen = 400,                        -- ms to wait for mapped key sequence to complete
	spell = false,                           -- enable spellcheck
	spelllang = "en",                        -- spellcheck language
	numberwidth = 4,                         -- number column width

	-- Markdown specific settings
	breakindent = true, -- Match indent on line break
	linebreak = true -- Line break on whole words

	-- showtabline = 2,                             -- always show the tab line
}
-- Allow j/k when navigating wrapped lines
vim.keymap.set({ "n", "v", }, "j", "gj")
vim.keymap.set({ "n", "v", }, "k", "gk")

-- Apply options
for k, v in pairs(options) do o[k] = v end

local g = vim.g
local globals = {
	netrw_browse_split = 0,
	netrw_banner = 0,
	netrw_winsize = 25
}

for k, v in pairs(globals) do g[k] = v end
