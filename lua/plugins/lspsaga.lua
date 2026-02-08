return {
	"nvimdev/lspsaga.nvim",
	event = "LspAttach",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		lightbulb = { enable = false },
		outline = { auto_open = false },
		-- Neovim 0.12 以降の非推奨API警告を避けるため symbol 機能を明示無効
		symbol = { enable = false },
	},
}
