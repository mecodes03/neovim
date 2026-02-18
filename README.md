# mecodes — Neovim Config

My personal Neovim config. Uses **lazy.nvim** for plugin management and **rose-pine (moon)** as the default colorscheme.

## Structure

```
init.lua                    → Entry point, just does require("mecodes")
lua/mecodes/
├── init.lua                → Loads all core modules + sets up autocmds (yank highlight,
│                             trailing whitespace trim, LSP keymaps, document highlights)
├── lazy_init.lua           → Bootstraps lazy.nvim & points it at lua/mecodes/lazy/
├── remap.lua               → All keymaps (leader = Space)
├── set.lua                 → Vim options (4-space indent, relative numbers, persistent undo, etc.)
├── constants.lua           → Shared constants (INDENT_SIZE, TAB_WIDTH, LINE_LENGTH)
├── icons.lua               → Icon definitions used by LSP completion, diagnostics, git, UI
├── transparency.lua        → Toggle transparency with <leader>tr, ColorMyPencils() helper
└── lazy/                   → One file per plugin (lazy.nvim auto-discovers these)
    ├── amp.lua             → Amp AI assistant
    ├── bufferline.lua      → Buffer tabs
    ├── colors.lua          → Colorschemes (rose-pine, tokyonight, catppuccin, onedark)
    ├── conform.lua         → Auto-formatting
    ├── fugitive.lua        → Git (vim-fugitive)
    ├── gitsigns.lua        → Git gutter signs
    ├── harpoon.lua         → Quick file switching
    ├── highlight_colors.lua→ Inline color previews
    ├── leap.lua            → Motion plugin
    ├── lsp.lua             → LSP + Mason + nvim-cmp (completions, snippets, diagnostics)
    ├── lua-line.lua        → Statusline
    ├── misc.lua            → Small one-off plugins
    ├── nvim-lint.lua       → Linting
    ├── snippets.lua        → Custom snippets
    ├── telescope.lua       → Fuzzy finder
    ├── treesitter.lua      → Syntax highlighting / parsing
    ├── trouble.lua         → Diagnostics list
    ├── ufo.lua             → Code folding
    ├── undotree.lua        → Undo history visualizer
    └── markdown.lua        → Markdown Reader
after/lsp/                  → Per-server LSP overrides (lua_ls, tailwindcss)
```

## Key Keymaps

| Key | Mode | Action |
|-----|------|--------|
| `<Space>` | — | Leader |
| `<leader>e` | n | Open netrw |
| `<C-s>` | n | Save |
| `<C-x>` | n | Quit |
| `<C-d>` / `<C-f>` | n | Scroll down / up (centered) |
| `<Tab>` / `<S-Tab>` | n | Next / prev buffer |
| `<leader>y` | n,v | Yank to system clipboard |
| `<leader>p` | x | Paste without overwriting clipboard |
| `<leader>/` | n,v | Toggle comment |
| `<leader>rr` | n | Search & replace word under cursor |
| `<leader>rn` | n | LSP rename |
| `<leader>ca` | n | Code action |
| `<leader>d` | n | Open diagnostic float |
| `gd` / `gD` / `gi` / `gt` | n | Go to def / declaration / impl / type def |
| `<leader>tr` | n | Toggle transparency |
| `<leader>tm` | n | Toggle mouse |
| `<leader>la` | n | Open Lazy plugin manager |
| `V` + `J`/`K` | v | Move selected lines down/up |
| Arrow keys | n | Resize splits |

## LSP Servers (via Mason)

lua_ls, rust_analyzer, gopls, html, tailwindcss, dockerls, prismals, pyright

## How It Works

1. `init.lua` requires `mecodes` → `lua/mecodes/init.lua`
2. That file loads options, keymaps, constants, icons, transparency, and bootstraps lazy.nvim
3. lazy.nvim auto-discovers every file in `lua/mecodes/lazy/` as a plugin spec
4. LSP keymaps are set dynamically via an `LspAttach` autocmd (not per-plugin)
5. Server-specific LSP config overrides go in `after/lsp/<server>.lua`

## Notes

- Mouse is **disabled** by default (`<leader>tm` to toggle)
- Persistent undo is saved to `~/.vim/undodir`
- Trailing whitespace is auto-stripped on save
- Colorscheme defaults to **rose-pine moon** (swap in `transparency.lua` → `ColorMyPencils()`)
