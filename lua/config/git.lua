local M = {}

-- 単一タブで Lazygit をトグル（レイアウト破綻を避ける）
M._tab = nil
M._win = nil
M._buf = nil

local function git_root()
  local cwd = vim.loop.cwd() or vim.fn.getcwd()
  local out = vim.fn.systemlist({ "bash", "-lc", "git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel" })
  if type(out) == "table" and #out > 0 and out[1] ~= "" then
    return out[1]
  end
  return cwd
end

local function reset_state()
  M._tab, M._win, M._buf = nil, nil, nil
end

function M.toggle_lazygit()
  if M._tab and vim.api.nvim_tabpage_is_valid(M._tab) then
    pcall(vim.api.nvim_set_current_tabpage, M._tab)
    vim.cmd("tabclose")
    reset_state()
    return
  end

  local cmd
  if vim.fn.executable("lazygit") == 1 then
    cmd = { "bash", "-lc", "lazygit" }
  else
    cmd = { "bash", "-lc", "git status; echo; echo 'Install lazygit with: brew install lazygit'; read -n1 -p 'press any key to close...'" }
  end

  local root = git_root()
  vim.cmd("tabnew")
  M._tab = vim.api.nvim_get_current_tabpage()
  M._win = vim.api.nvim_get_current_win()
  M._buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(M._win, M._buf)
  vim.bo[M._buf].bufhidden = "hide"
  vim.bo[M._buf].filetype = "lazygit"
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = "no"
  vim.opt_local.winbar = ""
  vim.fn.termopen(cmd, {
    cwd = root,
    on_exit = function()
      if M._tab and vim.api.nvim_tabpage_is_valid(M._tab) then
        pcall(vim.api.nvim_set_current_tabpage, M._tab)
        pcall(vim.cmd, "tabclose")
      end
      reset_state()
    end,
  })
  vim.cmd("startinsert")
end

return M
