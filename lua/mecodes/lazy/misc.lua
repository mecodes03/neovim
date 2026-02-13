return {
	{
		"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
	},
	{
		"folke/todo-comments.nvim", -- Highlight todo, notes, etc in comments
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = true },
	},
}
