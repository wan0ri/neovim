-- mappingはinit.lua側に直結で定義済み。ここでは関数定義は持たない。

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  event = "VeryLazy",
  -- キーマップは init.lua で設定
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return math.floor(vim.o.lines * 0.30)
      elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.40)
      end
      return 20
    end,
    open_mapping = [[<leader>`]],
    direction = "horizontal",
    shade_terminals = true,
    start_in_insert = true,
    persist_mode = false,
    close_on_exit = true,
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)
  end,
}
