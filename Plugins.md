# Plugins

主要プラグインの目的と代表的なコマンド/操作を一覧化します。カテゴリごとに必要最小限のみ記載しています。

---

## UI / 起動画面

- dashboard-nvim
  - 起動時に最近ファイルとショートカットを表示
  - `:Dashboard` / `Leader+dd`

- nvim-scrollbar
  - 右端にスクロールバー＋マークを表示（検索/診断/Git 変更）
  - 除外: `dashboard`, `neo-tree`, `help`, `lazy`, `mason`, `Telescope*`

- lualine.nvim
  - ステータスライン（Tokyonight テーマ）。Git（branch/diff）と診断（error/warn/info/hint）を色分け表示

- indent-blankline.nvim（ibl）
  - インデントガイド。`dashboard` や `neo-tree` では非表示

- hlchunk.nvim
  - ブロック（関数/if など）の境界を可視化
  - Tokyonight パレットに追従（通常: cyan/blue、エラー: magenta/red）

---

## カラースキーム

- tokyonight.nvim（既定）
  - 現行スタイル: `night`（透過なし）
  - 変更例: `:lua require('tokyonight').setup({ style = 'storm' }); vim.cmd.colorscheme('tokyonight')`
- which-key からの簡易切替: `<leader>un`（night）, `<leader>us`（storm）, `<leader>um`（moon）
  - 追加トグル: `<leader>ut`（transparent 切替）, `<leader>ui`（comments/keywords 斜体の切替）
- cobalt2.nvim（Cobalt2 Theme Official 互換）
  - 切替: `<leader>uc` または `:Cobalt2Enable`

- nvim-transparent（背景透過の一括管理）
  - トグル: `<leader>uT`（TransparentToggle）
  - 端末（WezTerm等）の透過/ぼかし設定をそのまま反映
- vscode.nvim（代替）
- cobalt2.nvim（代替・必要時のみ手動適用）

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
  - フロート枠の色はカラースキーム（Tokyonight）の `FloatBorder` に委譲

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

- neodev.nvim（Lua 開発補助）
  - lua_ls に Neovim API の型情報を提供し、`vim.*` の誤検知を軽減

- nvim-cmp（補完エンジン）
  - `<C-Space>` で補完メニュー、`<Tab>/<S-Tab>` で移動、`<CR>` で確定
  - ソース: `nvim_lsp` / `nvim_lsp_signature_help` / `path` / `buffer` / `luasnip`
  - 付加機能:
    - lspkind.nvim（VSCode風アイコン/ラベル）
    - cmp-nvim-lsp-signature-help（関数シグネチャを補完候補に同居）
    - nvim-autopairs（括弧の自動補完。確定時の括弧連携）

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

- markdown-preview.nvim
  - `:MarkdownPreview` / `:MarkdownPreviewStop` / `:MarkdownPreviewToggle`
  - 既定ブラウザでプレビュー（保存で自動更新）。初回は Node.js が必要（`:Lazy sync` 後に自動ビルド）

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
