function LintProgress()
	local linters = require("lint").get_running()
	if #linters == 0 then
		return "󰦕"
	end
	return "󱉶 " .. table.concat(linters, ", ")
end

return {
	"https://github.com/mfussenegger/nvim-lint.git",
	config = function()
		require("lint").linters_by_ft = {
			-- javascript = { "eslint_d" },
			-- typescript = { "eslint_d" },
			solidity = { "solhint" },
		}
	end,
}
