return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "zbirenbaum/copilot.lua" },
	opts = {},
	keys = {
		{ "<leader>co", ":CopilotChatOpen<CR>", desc = "CopilotChat: Open" },
		{ "<leader>cc", ":CopilotChat<CR>", desc = "CopilotChat: Prompt" },
		{ "<leader>cq", ":CopilotChatClose<CR>", desc = "CopilotChat: Close" },
	},
}
