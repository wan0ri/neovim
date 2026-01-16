return {
	"Wansmer/treesj",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	keys = {
		{
			"<leader>tj",
			function()
				require("treesj").toggle()
			end,
			desc = "Treesj: toggle split/join",
		},
	},
	opts = { use_default_keymaps = false },
}
