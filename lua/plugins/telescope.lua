return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {"<C-p>", function() require("telescope.builtin").find_files() end, desc = "Quick Open (files)"},
    {"<leader>fa", function() require("telescope.builtin").find_files({ no_ignore = true, hidden = true }) end, desc = "Find files (ALL: hidden & gitignored)"},
    {"<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files"},
    {"<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Search in files"},
    {"<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Find buffers"},
    {"<leader>sp", function() require("telescope.builtin").commands() end, desc = "Command Palette"},
  },
}
