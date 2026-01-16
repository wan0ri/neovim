return {
	"mfussenegger/nvim-lint",
	config = function()
		local lint = require("lint")
		-- Prefer markdownlint-cli2 if available
		if vim.fn.executable("markdownlint-cli2") == 1 then
			lint.linters.markdownlint = {
				cmd = "markdownlint-cli2",
				args = { "--stdin" },
				stdin = true,
				ignore_exitcode = true,
				parser = require("lint.parser").from_errorformat("%f:%l:%c %m", {
					source = "markdownlint-cli2",
				}),
			}
		end
	end,
}
