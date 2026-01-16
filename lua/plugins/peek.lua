return {
	"toppair/peek.nvim",
	build = "deno task --quiet build:fast",
	cmd = { "PeekOpen", "PeekClose" },
	keys = {
		{ "<leader>mP", ":PeekOpen<CR>", desc = "Markdown: Peek open" },
		{ "<leader>mX", ":PeekClose<CR>", desc = "Markdown: Peek close" },
	},
	opts = { theme = "light" },
}
