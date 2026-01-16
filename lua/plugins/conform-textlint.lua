return {
	"stevearc/conform.nvim",
	config = function()
		local conform = require("conform")
		conform.formatters = conform.formatters or {}
		-- Use textlint --fix when available for Markdown
		conform.formatters.textlint = {
			command = (vim.fn.executable("textlint") == 1) and "textlint"
				or ((vim.fn.executable("npx") == 1) and "npx" or "textlint"),
			args = (function()
				if vim.fn.executable("textlint") == 1 then
					return { "--fix", "--stdin", "--stdin-filename", "$FILENAME" }
				elseif vim.fn.executable("npx") == 1 then
					return { "-y", "textlint", "--fix", "--stdin", "--stdin-filename", "$FILENAME" }
				else
					return { "--fix", "--stdin", "--stdin-filename", "$FILENAME" }
				end
			end)(),
			stdin = true,
			cwd = require("conform.util").root_file({
				".textlintrc",
				".textlintrc.json",
				".textlintrc.yml",
				".textlintrc.yaml",
			}),
		}
		-- Prepend textlint for markdown; keep Prettier fallback
		local fb = require("conform").formatters_by_ft or {}
		fb.markdown = fb.markdown or { "prettierd", "prettier" }
		table.insert(fb.markdown, 1, "textlint")
		conform.formatters_by_ft = fb
	end,
}
