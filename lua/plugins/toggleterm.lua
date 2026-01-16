-- mappingはinit.lua側に直結で定義済み。ここでは関数定義は持たない。

return {
	"akinsho/toggleterm.nvim",
	version = "*",
	event = "VeryLazy",
	-- キーマップは init.lua で設定
	opts = {
		size = function(term)
			if term.direction == "horizontal" then
				return math.floor(vim.o.lines * 0.30)
			elseif term.direction == "vertical" then
				return math.floor(vim.o.columns * 0.40)
			end
			return 20
		end,
		open_mapping = [[<leader>`]],
		direction = "horizontal",
		shade_terminals = true,
		start_in_insert = true,
		persist_mode = false,
		close_on_exit = true,
	},
	keys = {
		{ "<leader>tt", ":ToggleTerm<CR>", desc = "Terminal: toggle (bottom)" },
		{ "<leader>tv", ":ToggleTerm direction=vertical<CR>", desc = "Terminal: vertical" },
		{ "<leader>tf", ":ToggleTerm direction=float<CR>", desc = "Terminal: float" },
	},
	config = function(_, opts)
		require("toggleterm").setup(opts)
		vim.api.nvim_create_autocmd("TermOpen", {
			pattern = "*",
			callback = function()
				pcall(vim.keymap.set, "t", "<Esc>", [[<C-\><C-n>]], { buffer = 0 })
				pcall(vim.keymap.set, "t", "jk", [[<C-\><C-n>]], { buffer = 0 })
				-- t-mode からもトグルできるように（Esc不要）
				pcall(vim.keymap.set, "t", "<leader>tt", [[<C-\><C-n>:ToggleTerm<CR>]], { buffer = 0, silent = true })
				vim.opt_local.number = false
				vim.opt_local.relativenumber = false
				vim.opt_local.signcolumn = "no"
			end,
		})
	end,
}
