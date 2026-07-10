return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup({})

			-- List Using Telescope
			vim.keymap.set("n", "<leader>A", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Open harpoon window [telescope]" })

			-- Append Harpoon
			vim.keymap.set("n", "<leader>ah", function()
				harpoon:list():add()
			end, {
				desc = "harpoon append file",
			})

			-- Harpoon Select
			vim.keymap.set("n", "<leader>1", function()
				harpoon:list():select(1)
			end, {
				desc = "harpoon select 1",
			})
			vim.keymap.set("n", "<leader>2", function()
				harpoon:list():select(2)
			end, {
				desc = "harpoon select 2",
			})
			vim.keymap.set("n", "<leader>3", function()
				harpoon:list():select(3)
			end, {
				desc = "harpoon select 3",
			})
			vim.keymap.set("n", "<leader>4", function()
				harpoon:list():select(4)
			end, {
				desc = "harpoon select 4",
			})

			vim.keymap.set("n", "<M-j", function()
				harpoon:list():next({ ui_nav_wrap = true }) -- enable cycling through list
			end, {
				desc = "harpoon next",
			})

			vim.keymap.set("n", "<M-k", function()
				harpoon:list():prev({ ui_nav_wrap = true }) -- enable cycling through list
			end, {
				desc = "harpoon prev",
			})
		end,
	},
}
