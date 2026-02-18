-- Force transparent backgrounds
local transparency = true
local color_scheme = "rose-pine"

---@param color string
function ColorMyPencils(color)
	color = color or color_scheme
	color_scheme = color
	vim.cmd.colorscheme(color)

	if transparency then
		MakeTransparence()
	end
end

function ToggleTransparency()
	if transparency then
		transparency = false
	else
		transparency = true
	end

	ColorMyPencils(color_scheme)
end

function MakeTransparence()
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })

	-- make float buffers transparent
	-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

local function force_transparency()
	local groups = {
		"EndOfBuffer",
		"FloatBorder",
		"Folded",
		"Function",
		"Identifier",
		"MoreMsg",
		"MsgArea",
		"NonText",
		"Normal",
		"NormalFloat",
		"NormalNC",
		"NvimTreeNormal",
		"Operator",
		"PreProc",
		"Repeat",
		"SignColumn",
		"Special",
		"Statement",
		"StatusLine",
		"String",
		"Structure",
		"TabLine",
		"Todo",
		"Type",
		"Underlined",
	}

	for _, group in ipairs(groups) do
		vim.api.nvim_set_hl(0, group, { bg = "none" })
	end
end

return {
	{
		"folke/tokyonight.nvim",
		name = "tokyonight",
		config = function()
			require("tokyonight").setup({
				style = "night", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
				transparent = transparency, -- Enable this to disable setting the background color
				terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
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
			if color_scheme == 'tokyonight' then
				ColorMyPencils("tokyonight")
			end
		end,
	},

	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				transparent_background = transparency,
				term_colors = true,
				no_italic = true,
				no_bold = true,
				integrations = {
					cmp = true,
					nvimtree = true,
					treesitter = true,
				},
			})
			if color_scheme == "catppuccin" then
				ColorMyPencils("catppuccin")
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
						kurface = "#2e2b45",
					},
				},
				styles = {
					bold = false,
					italic = false,
					-- transparency = transparency.Transparency, -- this is making everything transparent
				},
				enable = { terminal = true },
			})

			if color_scheme == "rose-pine" then
				ColorMyPencils("rose-pine")
			end
		end,
	},
}
