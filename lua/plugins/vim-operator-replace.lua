return {
	"kana/vim-operator-user",
	dependencies = { "kana/vim-operator-replace" },
	config = function()
		-- replace operator: gr
		vim.keymap.set({ "n", "x" }, "gr", "<Plug>(operator-replace)", { desc = "Operator: replace" })
	end,
}
