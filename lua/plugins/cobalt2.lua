return {
  "lalitmee/cobalt2.nvim",
  lazy = false,
  priority = 999,
  config = function()
    local function apply_cobalt2_extras()
      local set = vim.api.nvim_set_hl
      local colors = {
        cyan = "#9EFFFF",
        yellow = "#FFC600",
        orange = "#FF9D00",
        green = "#A5FF90",
        pink = "#FF6C99",
        blue = "#22C7FF",
        fg = "#E1EFFF",
      }
      set(0, "@string", { fg = colors.green })
      set(0, "@number", { fg = colors.orange })
      set(0, "@boolean", { fg = colors.orange })
      set(0, "@constant", { fg = colors.pink })
      set(0, "@keyword", { fg = colors.blue, italic = true })
      set(0, "@type", { fg = colors.cyan })
      set(0, "@type.builtin", { fg = colors.cyan, italic = true })
      set(0, "@function", { fg = colors.cyan, bold = true })
      set(0, "@method", { fg = colors.cyan })
      set(0, "@property", { fg = colors.yellow })
      set(0, "@field", { fg = colors.yellow })
      set(0, "@label", { fg = colors.yellow })
      set(0, "@variable", { fg = colors.fg })
      pcall(set, 0, "@attribute.hcl", { fg = colors.yellow })
      pcall(set, 0, "@property.hcl", { fg = colors.yellow })
      pcall(set, 0, "@type.terraform", { fg = colors.cyan })
      pcall(set, 0, "@property.terraform", { fg = colors.yellow })
    end

    if vim.g.colors_name == "cobalt2" then
      apply_cobalt2_extras()
    end
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "cobalt2",
      callback = apply_cobalt2_extras,
    })
  end,
}

