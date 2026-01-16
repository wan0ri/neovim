return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewFileHistory",
	},
	keys = {
		{ "<leader>gd", ":DiffviewOpen<CR>", desc = "Git: Diffview open" },
		{ "<leader>gD", ":DiffviewClose<CR>", desc = "Git: Diffview close" },
		{ "<leader>gH", ":DiffviewFileHistory %<CR>", desc = "Git: File history (current)" },
	},
	config = function()
		require("diffview").setup({
			enhanced_diff_hl = true,
			view = { merge_tool = { layout = "diff3_mixed" } },
		})
	end,
}
