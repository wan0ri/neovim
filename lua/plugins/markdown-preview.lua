return {
  "iamcco/markdown-preview.nvim",
  ft = { "markdown" },
  cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop" },
  build = function()
    pcall(function() vim.fn["mkdp#util#install"]() end)
  end,
  init = function()
    vim.g.mkdp_open_to_the_world = 0
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_theme = "auto"
  end,
}

