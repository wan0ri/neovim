return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	config = function()
		require("treesitter-context").setup({
			enable = true,
			max_lines = 3,
			multiline_threshold = 5,
			trim_scope = "outer",
			mode = "cursor",
			separator = "─",
		})
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "dashboard", "neo-tree", "help", "lazy", "mason", "gitcommit", "toggleterm" },
			callback = function()
				pcall(require("treesitter-context").disable)
			end,
		})
		pcall(vim.api.nvim_set_hl, 0, "TreesitterContext", { default = true })
		pcall(vim.api.nvim_set_hl, 0, "TreesitterContextLineNumber", { default = true })
		pcall(vim.api.nvim_set_hl, 0, "TreesitterContextSeparator", { fg = "#22C7FF" })
		vim.keymap.set("n", "<leader>ct", ":TSContextToggle<CR>", { desc = "Context: toggle" })
		vim.keymap.set("n", "[c", function()
			pcall(require("treesitter-context").go_to_context)
		end, { desc = "Context: jump up" })
	end,
}
