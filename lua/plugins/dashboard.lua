return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local db = require("dashboard")
    db.setup({
      theme = "hyper",
      config = {
        week_header = { enable = true },
        mru = { limit = 8 },
        shortcut = {
          { desc = "Files", group = "Label", key = "f", action = "Telescope find_files" },
          { desc = "Grep", group = "DiagnosticHint", key = "g", action = "Telescope live_grep" },
          { desc = "NeoTree", group = "String", key = "e", action = "Neotree toggle" },
          { desc = "Update", group = "Exception", key = "u", action = "Lazy sync" },
        },
        footer = function() return { "Happy hacking with Neovim." } end,
      },
    })
    vim.keymap.set("n", "<leader>dd", ":Dashboard<CR>", { desc = "Open dashboard" })
  end,
}

