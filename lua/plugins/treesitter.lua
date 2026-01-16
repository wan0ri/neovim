return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			highlight = { enable = true, additional_vim_regex_highlighting = { "terraform", "hcl", "yaml" } },
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"yaml",
				"json",
				"bash",
				"dockerfile",
				"hcl",
				"terraform",
			},
		})
	end,
}
