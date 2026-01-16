return {
	"toppair/peek.nvim",
	cond = function()
		return vim.fn.executable("deno") == 1
	end,
	build = "deno task --quiet build:fast",
	cmd = { "PeekOpen", "PeekClose" },
	keys = {
		{ "<leader>mP", ":PeekOpen<CR>", desc = "Markdown: Peek open" },
		{ "<leader>mX", ":PeekClose<CR>", desc = "Markdown: Peek close" },
	},
	opts = { theme = "light" },
}
