return {
	"norcalli/nvim-colorizer.lua",
	config = function()
		require("colorizer").setup({
			"css",
			"javascript",
			"json",
			html = {
				mode = "foreground",
			},
		})
	end,
}
