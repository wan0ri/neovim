return {
	"romgrk/barbar.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	init = function()
		vim.g.barbar_auto_setup = false
	end,
	opts = { sidebar_filetypes = { undotree = true, neo_tree = true } },
	keys = {
		{
			"<leader>1",
			function()
				require("bufferline").go_to_buffer(1, true)
			end,
			desc = "Buffer 1",
		},
		{
			"<leader>2",
			function()
				require("bufferline").go_to_buffer(2, true)
			end,
			desc = "Buffer 2",
		},
		{ "<leader>bn", ":BufferNext<CR>", desc = "Next buffer" },
		{ "<leader>bp", ":BufferPrevious<CR>", desc = "Prev buffer" },
		{ "<leader>bd", ":BufferClose<CR>", desc = "Close buffer" },
	},
	config = function(_, opts)
		require("barbar").setup(opts)
	end,
}
