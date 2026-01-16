return {
	"nvimdev/lspsaga.nvim",
	event = "LspAttach",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		lightbulb = { enable = false },
		outline = { auto_open = false },
	},
}
