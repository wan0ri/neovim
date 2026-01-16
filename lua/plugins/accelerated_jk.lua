return {
  "rainbowhxch/accelerated-jk.nvim",
  event = "VeryLazy",
  config = function()
    require("accelerated-jk").setup({
      mode = "time_driven",
      enable_deceleration = true,
      acceleration_motions = { "h", "j", "k", "l" },
    })
    vim.keymap.set("n", "j", "<Plug>(accelerated_jk_j)")
    vim.keymap.set("n", "k", "<Plug>(accelerated_jk_k)")
  end,
}

