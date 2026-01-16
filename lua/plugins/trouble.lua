return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = { "Trouble", "TroubleToggle" },
	keys = {
		{ "<leader>xx", ":TroubleToggle<CR>", desc = "Trouble: toggle" },
	},
	opts = {},
}
