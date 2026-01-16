return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		options = {
			theme = "tokyonight",
			section_separators = "",
			component_separators = "",
			globalstatus = true,
			disabled_filetypes = { statusline = { "toggleterm" }, winbar = { "toggleterm" } },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff" },
			lualine_c = { { "diagnostics", sources = { "nvim_diagnostic" } } },
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	},
}
