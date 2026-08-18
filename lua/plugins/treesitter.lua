return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local parser_root = vim.fn.stdpath("config") .. "/ts-parsers"
		vim.fn.mkdir(parser_root, "p")

		-- Neovim本体更新後も古いparserを拾わないよう、config配下へ固定する
		if not vim.tbl_contains(vim.opt.runtimepath:get(), parser_root) then
			vim.opt.runtimepath:prepend(parser_root)
		end

		require("nvim-treesitter.configs").setup({
			parser_install_dir = parser_root,
			highlight = {
				-- Neovim 0.12.4 環境で highlighter が不安定なため、まず全面停止する
				enable = false,
				additional_vim_regex_highlighting = { "terraform", "hcl", "yaml", "markdown" },
			},
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
				"markdown",
				"markdown_inline",
			},
		})
	end,
}
