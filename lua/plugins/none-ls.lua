return {
	"nvimtools/none-ls.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				-- 軽めの安全なコードアクションのみ有効化
				null_ls.builtins.code_actions.gitsigns,
			},
		})
	end,
}
