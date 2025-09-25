return {
	"akinsho/bufferline.nvim", -- Bufferbar
	dependencies = {
		"rose-pine/neovim",
	},
	config = function()
		local bufferline = require("bufferline")
		bufferline.setup({
			options = {
				style_preset = {
					bufferline.style_preset.no_italic,
					bufferline.style_preset.no_bold,
				},
				numbers = "none", -- | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
				close_command = "bdelete! %d",
				right_mouse_command = "bdelete! %d",
				left_mouse_command = "buffer %d",
				middle_mouse_command = nil,
				modified_icon = "●",
				left_trunc_marker = "",
				right_trunc_marker = "",
				max_name_length = 30,
				tab_size = 20,
				diagnostics = false, -- false | "nvim_lsp" | "coc"
				diagnostics_update_in_insert = false,
				offsets = { { filetype = "NvimTree", text = "", padding = 2 } },
				show_buffer_icons = true,
				show_buffer_close_icons = false,
				show_close_icon = false,
				show_tab_indicators = false,
				separator_style = { "", "" },
				enforce_regular_tabs = true,
				always_show_bufferline = true,
				indicator = {
					style = "none", -- "icon" | "underline" | "none"
				},
			},
			highlights = {
				buffer_selected = {
					bold = true,
					italic = true,
					fg = require("rose-pine.palette").rose,
					-- bg = require("rose-pine.palette").rose,
				},
				tab = { fg = require("rose-pine.palette").rose },
				buffer_visible = { fg = require("rose-pine.palette").rose },
			},
		})
	end,
}
