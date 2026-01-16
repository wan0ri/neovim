return {
  "xiyaowong/nvim-transparent",
  config = function()
    require("transparent").setup({
      enable = true,
      extra_groups = {
        "Normal","NormalNC","NormalFloat","FloatBorder",
        "Pmenu","PmenuSel",
        "TelescopeNormal","TelescopeBorder","TelescopePromptNormal",
        "TelescopeResultsNormal","TelescopePromptBorder","TelescopeResultsBorder",
        "NeoTreeNormal","NeoTreeNormalNC",
        "WhichKeyFloat","WhichKeyBorder",
        "MsgArea","SignColumn",
      },
      exclude = {},
    })
    vim.keymap.set("n", "<leader>uT", ":TransparentToggle<CR>", { desc = "UI: Transparent toggle" })
  end,
}

