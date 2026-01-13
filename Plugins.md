# Plugins

主要プラグインの目的と代表的なコマンド/操作を一覧化します。カテゴリごとに必要最小限のみ記載しています。

---

## UI / 起動画面

- dashboard-nvim
  - 起動時に最近ファイルとショートカットを表示
  - `:Dashboard` / `Leader+dd`

- lualine.nvim
  - ステータスライン（自動設定）

- indent-blankline.nvim（ibl）
  - インデントガイド。`dashboard` や `neo-tree` では非表示

- hlchunk.nvim
  - ブロック（関数/if など）の境界を可視化
  - Cobalt2 に合わせた色で描画（通常: `#22C7FF`, エラー: `#FF6C99`）

- dropbar.nvim
  - ウィンバーにパンくず（クラス/関数/シンボル）表示
  - 追加操作: `Leader+db`（メニューで要素選択）

- nvim-treesitter-context
  - 画面上部に現在のコンテキスト（関数/ブロック名）を固定表示
  - トグル: `<leader>ct`、上位へジャンプ: `[c`

---

## ファイル/検索

- telescope.nvim (+ telescope-fzf-native)
  - ファイル検索: `Ctrl-p` / `Leader+ff`
  - 全文検索（ripgrep）: `Leader+fg`
  - バッファ: `Leader+fb`
  - コマンドパレット: `Leader+sp`

- neo-tree.nvim
  - エクスプローラ: `Ctrl-b` でトグル

---

## ターミナル

- toggleterm.nvim
  - 下パネル: `&lt;leader&gt;tt`（または `&lt;leader&gt;`+バッククォートキー）
  - 右パネル: `<leader>tv`、フロート: `<leader>tf`
  - 端末内は `Esc` or `jk` でノーマル戻り

---

## Git

- gitsigns.nvim（行単位の差分/ステージ）
- neogit（Git UI）: `:Neogit`
- diffview.nvim（差分/履歴）: `:DiffviewOpen`, `:DiffviewClose`
- vim-fugitive（低レベル操作）: `:G ...`
- lazygit（toggleterm 連携）: `<leader>gg` でフロート表示/非表示（Git ルートで起動）

---

## LSP/補完/フォーマット/診断

- mason.nvim / mason-lspconfig.nvim / nvim-lspconfig
  - `:Mason` でツール管理。主要サーバは `init.lua` の `ensure_installed` に列挙

- nvim-cmp + LuaSnip
  - 補完エンジン。`<CR>` で確定（自動確定は無効）

- conform.nvim（Format）
  - 保存時自動フォーマット有効。手動は `Leader+f`
  - 主な対応: Markdown/JSON/YAML/Shell/Lua/Terraform（`terraform fmt`）
  - 依存バイナリは Mason で自動導入（下記 `mason-tool-installer`）

- nvim-lint（Lint）
  - 保存/挿入終了で実行（Markdown/YAML 既定）

- mason-tool-installer.nvim（ツール自動導入）
  - 起動時に主要フォーマッタ/リンタを自動インストール/更新
  - 既定で導入するツール例
    - `prettierd`, `prettier`（Markdown/JSON/YAML など）
    - `stylua`（Lua）, `shfmt`（Shell）, `yamlfmt`, `yamllint`（YAML）
    - `markdownlint`（Markdown）

---

## インフラ系

- vim-terraform
  - 整形は Conform.nvim の `terraform fmt` を使用（二重実行防止のためプラグイン側の自動整形は無効化済）

- vim-helm
  - Helm テンプレートの構文支援

---

## Markdown

- vim-table-mode
  - `:TableModeToggle`（表の整形）

- glow.nvim
  - `:Glow`（プレビュー、終了は `q`）

補足（Markdown 整形）

- 保存時に Prettierd → Prettier の順で利用できる方を自動選択して整形します
- うまく整形されない場合は、プロジェクトに `.prettierrc` を用意してください

---

## AI

- copilot.vim（インライン補完）
  - 初回 `:Copilot auth`
  - Tab 競合があれば `copilot_no_tab_map` を調整

- CopilotChat.nvim（チャット）
  - `<leader>co`（Open）, `<leader>cc`（Prompt）, `<leader>cq`（Close）

---

## ナビゲーション/移動

- accelerated-jk.nvim
  - `j/k` 長押しで加速度スクロール
