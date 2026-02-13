return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				-- A list of parser names, or "all"
				ensure_installed = {},
				sync_install = false, -- Install parsers synchronously (only applied to `ensure_installed`)
				-- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
				auto_install = true, -- Automatically install missing parsers when entering buffer
				indent = { enable = true, disable = { "yaml", "python" } },
				highlight = {
					-- `false` will disable the whole extension
					enable = true,
					disable = { "" },
					additional_vim_regex_highlighting = { "markdown" },
				},
				hijack_directories = {
					enable = true,
					auto_open = true,
				},
				-- EXTENSIONS
				-- Autopair brackets, strings etc. (windwp/nvim-autopairs)
				autopairs = {
					enable = true,
				},
			})
		end,
	},

	{
		-- Auto-tags for html, jsx, etc.
		"windwp/nvim-ts-autotag",
		opts = {
			opts = {
				-- Defaults
				enable_close = true, -- Auto close tags
				enable_rename = true, -- Auto rename pairs of tags
				enable_close_on_slash = false, -- Auto close on trailing </
			},
		},
	},

	{
		"windwp/nvim-autopairs", -- auto pair brackets, quotations etc.
		event = "InsertEnter",
		opts = {
			check_ts = true,
			ts_config = {
				lua = { "string", "source" },
				javascript = { "string", "template_string" },
				java = false,
			},
			disable_filetype = { "TelescopePrompt", "spectre_panel" },
			fast_wrap = {
				map = "<C-e>",
				chars = { "{", "[", "(", '"', "'" },
				pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
				offset = 0, -- Offset from pattern match
				end_key = "$",
				keys = "qwertyuiopzxcvbnmasdfghjkl",
				check_comma = true,
				highlight = "PmenuSel",
				highlight_grey = "LineNr",
			},
		},
	},

	{
		"nvim-treesitter/nvim-treesitter-context", -- Show current context at the top of the window
		opts = {
			enable = true,
			max_lines = 3,
			min_window_height = 0,
			line_numbers = true,
			multiline_threshold = 10,
			trim_scope = "outer", -- inner | outer
			mode = "cursor", -- cursor | topline
			separator = "",
		},
	},

	{
		"Wansmer/treesj", -- Join / split blocks of code
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			use_default_keymaps = false,
			check_syntax_error = true,
			max_join_length = 120,
			cursor_behavior = "start", -- hold | start | end
			notify = true,
			dot_repeat = true,
			on_error = nil,
		},

		keys = {
			{ "<leader>o", ":TSJToggle<CR>", desc = "Toggle join/split" },
		},
	},

	{
		"Wansmer/sibling-swap.nvim", -- Swap sibling treesitter nodes (e.g. move function argument to prev/next position, etc.)
		opts = {
			use_default_keymaps = false,
			highlight_node_at_cursor = false,
			ignore_injected_langs = false,
			allow_interline_swaps = true,
			interline_swaps_without_separator = false,
		},
		keys = {
			{
				"<leader><",
				":lua require('sibling-swap').swap_with_left()<CR>",
				desc = "Move node back",
			},
			{
				"<leader>>",
				":lua require('sibling-swap').swap_with_right()<CR>",
				desc = "Move node forward",
			},
		},
	},
}
