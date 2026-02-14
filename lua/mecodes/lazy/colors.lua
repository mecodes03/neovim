local transparency = require("mecodes.transparency")

---@param color string
function ColorMyPencils(color)
	local defaultColor = "rose-pine"
	color = color or defaultColor
	vim.cmd.colorscheme(color)

	if transparency.IS_FORCING_TRANSPARENCY then
		MakeTransparence()
	end
end

function ToggleTransparency()
	if transparency.IS_FORCING_TRANSPARENCY then
		transparency.IS_FORCING_TRANSPARENCY = false
	else
		transparency.IS_FORCING_TRANSPARENCY = true
	end

	ColorMyPencils("rose-pine")
end

function MakeTransparence()
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
	{
		"folke/tokyonight.nvim",
		name = "tokyo-night",
		config = function()
			require("tokyonight").setup({
				style = "moon",                         -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
				transparent = transparency.IS_FORCING_TRANSPARENCY, -- Enable this to disable setting the background color
				terminal_colors = true,                 -- Configure the colors used when opening a `:terminal` in Neovim
				styles = {
					-- Style to be applied to different syntax groups
					-- Value is any valid attr-list value for `:help nvim_set_hl`
					comments = { italic = false },
					keywords = { italic = false },
					-- Background styles. Can be "dark", "transparent" or "normal"
					sidebars = "dark", -- style for sidebars, see below
					floats = "dark", -- style for floating windows
				},
			})
		end,
	},

	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				transparent_background = transparency.IS_FORCING_TRANSPARENCY,
				term_colors = true,
				no_italic = true,
				no_bold = true,
				integrations = {
					cmp = true,
					nvimtree = true,
					treesitter = true,
				},
			})

			-- if transparency.IS_FORCING_TRANSPARENCY then
			-- 	transparency.force_transparency()
			-- end
		end,
	},

	{
		"Rolv-Apneseth/onedark.nvim", -- colourscheme
		name = "onedark",
		--[[ dev = true, ]]
		config = function()
			-- local onedark = require("onedark")
			-- if not onedark then
			-- 	return
			-- end

			require("onedark").setup({
				style = "darker",
				transparent = transparency.IS_FORCING_TRANSPARENCY,
				diagnostics = {
					background = not transparency.IS_FORCING_TRANSPARENCY,
				},
			})

			if transparency.IS_FORCING_TRANSPARENCY then
				transparency.force_transparency()
			end
		end,
	},

	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			require("rose-pine").setup({
				variant = "moon",
				dark_variant = "moon",
				dim_inactive_windows = true,
				palette = {
					moon = {
						base = "#15131f",
						_nc = "#131120",
						surface = "#222038",
						overlay = "#2e2b45",
					},
				},
				styles = {
					bold = false,
					italic = false,
					-- transparency = transparency.IS_FORCING_TRANSPARENCY, -- this is making everything transparent
				},
				enable = { terminal = true },
			})

			ColorMyPencils("rose-pine")
		end,
	},
}
