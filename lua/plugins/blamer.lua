return {
	"APZelos/blamer.nvim",
	init = function()
		vim.g.blamer_enabled = 0
	end,
	keys = { { "<leader>gB", ":BlamerToggle<CR>", desc = "Git: blame inline toggle" } },
}
