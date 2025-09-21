return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		vim.opt.termguicolors = true
		require("bufferline").setup({
			options = {
				diagnostics = "nvim_lsp",
				separator_style = "thin", -- or "thin" | "padded_slant" | "slant"
				show_buffer_close_icons = false,
				show_close_icon = false,
			},
			highlights = require("rose-pine.plugins.bufferline"),
		})
	end,
}
