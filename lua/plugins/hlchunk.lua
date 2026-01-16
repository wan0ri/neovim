return {
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local function hl_fg(name)
      local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
      if ok and hl and hl.fg then
        return string.format("#%06x", hl.fg)
      end
      return nil
    end
    local function hlchunk_colors()
      local normal = hl_fg("Function") or hl_fg("Type") or "#7dcfff"
      local error = hl_fg("DiagnosticError") or hl_fg("Error") or "#bb9af7"
      return { normal = normal, error = error }
    end

    require("hlchunk").setup({
      chunk = {
        enable = true,
        use_treesitter = true,
        style = (function()
          local c = hlchunk_colors()
          return { { fg = c.normal }, { fg = c.error } }
        end)(),
        chars = {
          horizontal_line = "─",
          vertical_line = "│",
          left_top = "┌",
          left_bottom = "└",
          right_arrow = "─",
        },
        exclude_filetypes = {
          "dashboard","neo-tree","help","lazy","mason",
          "TelescopePrompt","TelescopeResults","gitcommit",
        },
      },
      indent = { enable = false },
      line_num = { enable = false },
      blank = { enable = false },
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("HlchunkTokyonightColors", { clear = true }),
      pattern = "*",
      callback = function()
        local c = hlchunk_colors()
        pcall(require("hlchunk").setup, { chunk = { style = { { fg = c.normal }, { fg = c.error } } } })
      end,
    })
  end,
}

