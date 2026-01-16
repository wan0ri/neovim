return {
  "NeogitOrg/neogit",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Neogit",
  keys = {
    { "<leader>gn", ":Neogit kind=auto<CR>", desc = "Git: Neogit" },
  },
  opts = {
    disable_hint = true,
    integrations = { diffview = false },
  },
}

