return {
	"folke/trouble.nvim",
	cmd = { "Trouble" },
	opts = {
		focus = true,
		modes = {
			lsp = {
				win = { position = "right" },
			},
		},
	},

	keys = {
		{ "<leader>tt", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
		{
			"<leader>fj",
			function()
				if require("trouble").is_open() then
					require("trouble").prev({ skip_groups = true, jump = true })
				else
					local ok, err = pcall(vim.cmd.cprev)
					if not ok then
						vim.notify(err, vim.log.levels.ERROR)
					end
				end
			end,
			desc = "Previous Trouble/Quickfix Item",
		},
		{
			"<leader>fk",
			function()
				if require("trouble").is_open() then
					require("trouble").next({ skip_groups = true, jump = true })
				else
					local ok, err = pcall(vim.cmd.cnext)
					if not ok then
						vim.notify(err, vim.log.levels.ERROR)
					end
				end
			end,
			desc = "Next Trouble/Quickfix Item",
		},
	},
}
