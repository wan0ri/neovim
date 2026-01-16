return {
  "Mofiqul/vscode.nvim",
  config = function()
    require("vscode").setup({ transparent = false })
    -- vim.cmd.colorscheme("vscode") -- manual switch if needed
  end,
}

