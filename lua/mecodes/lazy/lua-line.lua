return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = "rose-pine", -- or your favorite theme
				section_separators = "",
				component_separators = "",
			},
			sections = {
				lualine_a = {
				},
				lualine_b = {
					{
						"filename",
						path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
						file_status = true,
						newfile_status = true,
						symbols = {
							modified = " ●", -- when file is modified
							readonly = " 🔒",
							unnamed = "[No Name]",
						},
						fmt = function(str)
							return "%#LualineFilename#" .. str .. "%*"
						end,
					},
				},
				lualine_c = {
					"diagnostics"
				},
				lualine_x = {
					{ "diff" },
					{ "branch" },
				},
				lualine_y = {},
				lualine_z = {},
			},
		})
	end,
}
