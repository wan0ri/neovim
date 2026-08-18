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
				enable = true,
				additional_vim_regex_highlighting = { "terraform", "hcl", "yaml", "markdown" },
				disable = function(lang, buf)
					local name = vim.api.nvim_buf_get_name(buf)
					if name ~= "" and vim.fn.isdirectory(name) == 1 then
						return true
					end
					return lang == "markdown" or lang == "markdown_inline"
				end,
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
