return {
	"pwntester/octo.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	cmd = { "Octo" },
	keys = {
		{ "<leader>op", ":Octo pr list<CR>", desc = "Octo: PR list" },
		{ "<leader>oc", ":Octo pr create<CR>", desc = "Octo: PR create" },
		{ "<leader>or", ":Octo review start<CR>", desc = "Octo: Review start" },
	},
	config = function()
		require("octo").setup({
			use_local_fs = true,
			default_remote = { "upstream", "origin" },
		})
	end,
}
