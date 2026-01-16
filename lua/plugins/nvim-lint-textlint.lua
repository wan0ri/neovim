-- Add textlint diagnostics for Markdown/Japanese spacing rules, if available
return {
	"mfussenegger/nvim-lint",
	config = function()
		local lint = require("lint")
		lint.linters.textlint = {
			cmd = (vim.fn.executable("textlint") == 1) and "textlint"
				or ((vim.fn.executable("npx") == 1) and "npx" or "textlint"),
			args = (function()
				if vim.fn.executable("textlint") == 1 then
					return {
						"-f",
						"unix",
						"-q",
						"--stdin",
						"--stdin-filename",
						function()
							return vim.api.nvim_buf_get_name(0)
						end,
					}
				elseif vim.fn.executable("npx") == 1 then
					return {
						"-y",
						"textlint",
						"-f",
						"unix",
						"-q",
						"--stdin",
						"--stdin-filename",
						function()
							return vim.api.nvim_buf_get_name(0)
						end,
					}
				else
					return {
						"-f",
						"unix",
						"-q",
						"--stdin",
						"--stdin-filename",
						function()
							return vim.api.nvim_buf_get_name(0)
						end,
					}
				end
			end)(),
			stdin = true,
			ignore_exitcode = true,
			env = nil,
			parser = require("lint.parser").from_errorformat("%f:%l:%c: %m", {
				source = "textlint",
			}),
		}
		-- Add textlint to Markdown filetype (alongside markdownlint)
		lint.linters_by_ft.markdown = lint.linters_by_ft.markdown or {}
		table.insert(lint.linters_by_ft.markdown, 1, "textlint")
	end,
}
