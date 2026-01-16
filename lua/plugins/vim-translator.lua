return {
	"voldikss/vim-translator",
	keys = {
		{ "<leader>tr", ":TranslateW<CR>", desc = "Translate: word" },
		{ "<leader>tR", ":TranslateW!<CR>", desc = "Translate: word (replace)" },
	},
	init = function()
		vim.g.translator_default_engines = { "google" }
	end,
}
