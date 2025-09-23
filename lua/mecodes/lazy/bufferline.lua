return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		vim.opt.termguicolors = true
		local bufferline = require("bufferline")
		require("bufferline").setup({
			options = {
				style_preset = bufferline.style_preset.no_italic,
				diagnostics = "nvim_lsp",
				separator_style = "slope", -- or "thin" | "padded_slant" | "slant"
				show_buffer_close_icons = false,
				show_close_icon = false,
				diagnostics_indicator = function(count, level)
					local icon = level:match("error") and " " or " "
					return " " .. icon .. count
				end,
			},
			highlights = require("rose-pine.plugins.bufferline"),
		})
	end,
}
