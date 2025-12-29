-- VSCode風 Neovim スターター（インフラ領域向け）
-- 配置先の想定: ~/.config/nvim/init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 基本オプション（VSCode寄り）
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 200
vim.opt.termguicolors = true
-- 検索ハイライトは普段はオフ。必要時だけ点灯（Escで消す）
vim.opt.hlsearch = true

-- Escで検索ハイライトを消す
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlight" })

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- テーマ（VSCode）: 併用可能。既定は cobalt2 を適用するため、ここでは切替のみ準備。
  {
    "Mofiqul/vscode.nvim",
    config = function()
      require("vscode").setup({ transparent = false })
      -- デフォルト適用はしない（cobalt2 を後段で適用）
      -- vim.cmd.colorscheme("vscode")
    end,
  },
  -- Cobalt2 テーマ（VSCode Cobalt2 に近い配色）
  { "rktjmp/lush.nvim" },
  { "tjdevries/colorbuddy.nvim" },
  {
    "lalitmee/cobalt2.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local ok = pcall(function()
        require("cobalt2").setup({})
        vim.cmd.colorscheme("cobalt2")
      end)
      if not ok then
        vim.cmd.colorscheme("vscode")
      end
      -- 透過を生かしたい場合は下記を有効化
      -- vim.api.nvim_set_hl(0, "Normal",      { bg = "none" })
      -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      -- Treesitter ハイライトの色分けを追加（Cobalt2 の色味に寄せる）
      local set = vim.api.nvim_set_hl
      local colors = {
        cyan   = "#9EFFFF",
        yellow = "#FFC600",
        orange = "#FF9D00",
        green  = "#A5FF90",
        pink   = "#FF6C99",
        blue   = "#22C7FF",
        fg     = "#E1EFFF",
      }
      set(0, "@string",       { fg = colors.green })
      set(0, "@number",       { fg = colors.orange })
      set(0, "@boolean",      { fg = colors.orange })
      set(0, "@constant",     { fg = colors.pink })
      set(0, "@keyword",      { fg = colors.blue, italic = true })
      set(0, "@type",         { fg = colors.cyan })
      set(0, "@type.builtin", { fg = colors.cyan, italic = true })
      set(0, "@function",     { fg = colors.cyan, bold = true })
      set(0, "@method",       { fg = colors.cyan })
      set(0, "@property",     { fg = colors.yellow })
      set(0, "@field",        { fg = colors.yellow })
      set(0, "@label",        { fg = colors.yellow })
      set(0, "@variable",     { fg = colors.fg })
      -- Terraform/HCL 強化（ある場合のみ適用）
      pcall(set, 0, "@attribute.hcl",     { fg = colors.yellow })
      pcall(set, 0, "@property.hcl",      { fg = colors.yellow })
      pcall(set, 0, "@type.terraform",    { fg = colors.cyan })
      pcall(set, 0, "@property.terraform",{ fg = colors.yellow })
    end,
  },

  -- Treesitter（基本の構文強調）
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true, additional_vim_regex_highlighting = { "terraform", "hcl", "yaml" } },
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "yaml",
          "json",
          "bash",
          "dockerfile",
          "hcl",
          "terraform",
        },
      })
    end,
  },

  -- ファイル検索/コマンドパレット
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function()
      return vim.fn.executable("make") == 1
    end,
    config = function()
      pcall(require("telescope").load_extension, "fzf")
    end,
  },

  -- エクスプローラ（VSCode Explorer相当）
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
          filtered_items = {
            visible = true,          -- 隠し/無視ファイルを一覧に表示（薄く表示）
            show_hidden_count = true,
            hide_dotfiles = false,   -- ドットファイルも表示
            hide_gitignored = false, -- .gitignore で無視されたファイルも表示
            never_show = { ".DS_Store" },
          },
        },
      })
      vim.keymap.set("n", "<C-b>", "<cmd>Neotree toggle<cr>")
    end,
  },

  -- ステータスライン
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({ options = { theme = "auto" } })
    end,
  },

  -- Git 連携
  { "lewis6991/gitsigns.nvim", config = true },
  -- Git UI/履歴（Git Graph 代替）
  { "NeogitOrg/neogit", dependencies = { "nvim-lua/plenary.nvim" } },
  { "sindrets/diffview.nvim" },
  { "tpope/vim-fugitive" },

  -- コメントトグル（gc/gcc）
  { "numToStr/Comment.nvim", config = true },

  -- which-key（キーチートシート）
  { "folke/which-key.nvim", config = true },

  -- インデントガイド（indent-rainbow代替）
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = { scope = { enabled = true }, indent = { char = "│" } },
  },

  -- LSP / 補完 / フォーマット
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "rafamadriz/friendly-snippets" },
  { "b0o/SchemaStore.nvim" },
  { "stevearc/conform.nvim" },
  { "mfussenegger/nvim-lint" },

  -- インフラ特化（Terraform/Helm）
  {
    "hashivim/vim-terraform",
    config = function()
      -- conform.nvimで統一するため自動fmtは無効
      vim.g.terraform_fmt_on_save = 0
      vim.g.terraform_align = 1
    end,
  },
  { "towolf/vim-helm" },

  -- Markdown（All in One / Table / Preview 代替）
  { "dhruvasagar/vim-table-mode" },
  { "ellisonleao/glow.nvim", config = true, cmd = "Glow" },
})

-- Telescope VSCode風キーマップ
local tb = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", tb.find_files, { desc = "Quick Open (files)" })
vim.keymap.set("n", "<leader>fa", function() tb.find_files({ no_ignore = true, hidden = true }) end,
  { desc = "Find files (ALL: hidden & gitignored)" })
vim.keymap.set("n", "<leader>ff", tb.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", tb.live_grep, { desc = "Search in files" })
vim.keymap.set("n", "<leader>fb", tb.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>sp", tb.commands, { desc = "Command Palette" })

-- コメント（Ctrl-/ は端末では届かない場合があるので WezTerm 側で送出を推奨）
pcall(function()
  local api = require("Comment.api")
  vim.keymap.set("n", "<C-/>", api.toggle.linewise.current, { desc = "Toggle comment" })
  vim.keymap.set("v", "<C-/>", function()
    api.toggle.linewise(vim.fn.visualmode())
  end, { desc = "Toggle comment" })
end)

-- nvim-cmp（Enterで自動確定しない: VSCodeの acceptSuggestionOnEnter=off 相当）
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "buffer" },
  },
  preselect = cmp.PreselectMode.None,
  completion = { completeopt = "menu,menuone,noinsert" },
})

-- LSP設定
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local on_attach = function(_, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end
  map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
  map("n", "gr", vim.lsp.buf.references, "References")
  map("n", "K", vim.lsp.buf.hover, "Hover")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
  map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
  map("n", "<leader>e", vim.diagnostic.open_float, "Line Diagnostics")
end

local mlsp = require("mason-lspconfig")
mlsp.setup({
  ensure_installed = {
    "terraformls",
    "yamlls",
    "jsonls",
    "dockerls",
    "bashls",
    "lua_ls",
    "helm_ls",
    "marksman",
  },
})

-- Mason のインストール先を自動的に使う共通ハンドラ（古いバージョンでも動くようフォールバック）
local function setup_server(server)
  local opts = { capabilities = capabilities, on_attach = on_attach }
  if server == "yamlls" then
    opts.settings = {
      yaml = {
        keyOrdering = false,
        validate = true,
        format = { enable = true },
        kubernetes = true,
        schemaStore = { enable = false, url = "" },
        schemas = require("schemastore").yaml.schemas(),
      },
    }
  elseif server == "jsonls" then
    opts.settings = {
      json = {
        validate = { enable = true },
        schemas = require("schemastore").json.schemas(),
      },
    }
  elseif server == "lua_ls" then
    opts.settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
      },
    }
  end
  lspconfig[server].setup(opts)
end

if type(mlsp.setup_handlers) == "function" then
  mlsp.setup_handlers({ function(server) setup_server(server) end })
else
  for _, server in ipairs(mlsp.get_installed_servers()) do
    setup_server(server)
  end
end

-- Format on Save（VSCode: editor.formatOnSave = true 相当）
require("conform").setup({
  format_on_save = {
    lsp_fallback = true,
    timeout_ms = 2000,
  },
  formatters_by_ft = {
    lua = { "stylua" },
    terraform = { "terraform_fmt" },
    hcl = { "terraform_fmt" },
    yaml = { "yamlfmt", "prettierd", "prettier" },
    json = { "prettierd", "prettier" },
    jsonc = { "prettierd", "prettier" },
    markdown = { "prettierd", "prettier" },
    sh = { "shfmt" },
  },
})

vim.keymap.set({"n","v"}, "<leader>f", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format" })

-- Lint（markdownlint 等）
local lint = require("lint")
lint.linters_by_ft = {
  markdown = { "markdownlint" },
  yaml = { "yamllint" },
}
local lint_grp = vim.api.nvim_create_augroup("NvimLintOnSave", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
  group = lint_grp,
  callback = function()
    local ft = vim.bo.filetype
    local names = lint.linters_by_ft[ft]
    if not names then return end
    local runnable = {}
    for _, name in ipairs(names) do
      local linter = lint.linters[name]
      if linter then
        local cmd = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
        local exe = type(cmd) == "table" and cmd[1] or cmd
        if vim.fn.executable(exe) == 1 then table.insert(runnable, name) end
      end
    end
    if #runnable > 0 then lint.try_lint(runnable) end
  end,
})

-- 便利: 保存時に末尾空白削除（VSCode設定に準拠）
local trim_group = vim.api.nvim_create_augroup("TrimWhitespaceOnSave", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = trim_group,
  pattern = "*",
  callback = function()
    vim.cmd([[%s/\s\+$//e]])
  end,
})
