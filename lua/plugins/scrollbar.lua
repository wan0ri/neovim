return {
  "petertriho/nvim-scrollbar",
  dependencies = { "lewis6991/gitsigns.nvim", "kevinhwang91/nvim-hlslens" },
  config = function()
    local ok, scrollbar = pcall(require, "scrollbar")
    if not ok then return end
    scrollbar.setup({
      excluded_filetypes = {
        "dashboard","neo-tree","help","lazy","mason",
        "TelescopePrompt","TelescopeResults",
      },
      excluded_buftypes = { "terminal", "nofile", "prompt" },
    })
    pcall(function() require("scrollbar.handlers.search").setup() end)
    pcall(function() require("scrollbar.handlers.gitsigns").setup() end)
    pcall(function() require("scrollbar.handlers.diagnostic").setup() end)
  end,
}

