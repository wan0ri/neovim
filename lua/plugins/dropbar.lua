return {
  "Bekaboo/dropbar.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("dropbar").setup({})
    vim.keymap.set("n", "<leader>db", function()
      pcall(require("dropbar.api").pick)
    end, { desc = "Dropbar: pick" })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "dashboard", "neo-tree", "help", "lazy", "mason", "gitcommit", "toggleterm" },
      callback = function()
        vim.opt_local.winbar = nil
      end,
    })
  end,
}

