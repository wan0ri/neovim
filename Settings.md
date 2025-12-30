## Settings

このドキュメントは導入後の運用・設定手順をまとめたものです。最初は README.md の基本操作を参照し、必要に応じてこのページで詳細を確認してください。

---

### 1) 初回セットアップ

- Neovim を起動すると `lazy.nvim` が自動でプラグイン取得（初回のみ）
- 取得が終わったら必要に応じて以下を実施
  - `:Lazy sync`（同期・更新）
  - `:checkhealth`（動作診断）

---

### 2) ツール（LSP/Formatter/Linter）のインストール（Mason）

- コマンド: `:Mason`
- 推奨（用途に応じて調整）
  - LSP: terraform-ls, yaml-language-server, json-lsp, dockerfile-language-server, bash-language-server, lua-language-server, helm-ls, marksman
  - Formatter: yamlfmt, prettierd または prettier, shfmt, stylua（Terraform は `terraform_fmt` 内蔵）
  - Linter: markdownlint, yamllint
- インストール先は `$HOME/.local/share/nvim/mason/bin`。必要なら `PATH` に追加

---

### 3) フォーマット/リンタ設定

- 保存時フォーマットは `conform.nvim` が有効（`init.lua` 末尾参照）
- 手動フォーマット: `<leader>f`（選択範囲にも対応）
- Lint は `nvim-lint` が `BufWritePost/InsertLeave` で実行
  - 既定: Markdown → markdownlint、YAML → yamllint

---

### 4) Copilot（AI 補助）

- 認証コマンド: `:Copilot auth`（初回は自動実行される設定）
- インライン補完: `github/copilot.vim`
  - Tab 競合があれば `init.lua` 内の `copilot_no_tab_map` を有効化して好みのキーに再割当
- チャット: `CopilotChat.nvim`
  - `<leader>co`（Open）, `<leader>cc`（Prompt）, `<leader>cq`（Close`）

---

### 5) テーマ/見た目

- 既定は `cobalt2`。失敗時は `vscode` にフォールバック
- 透過や色味は `init.lua` の「Cobalt2 テーマ設定」付近の `vim.api.nvim_set_hl` を編集
- `hlchunk.nvim` / `treesitter-context` / `dropbar` は Cobalt2 に合わせた配色（必要に応じて HEX を変更）

---

### 6) 起動画面（Dashboard）

- 自動表示（`VimEnter`）
- 手動: `<leader>dd` / `:Dashboard`
- 最近ファイルやショートカットはダッシュボード上のキー（`f`, `g`, `e`, `u`）で操作

---

### 7) ターミナル

- 下パネル: `toggleterm.nvim`
  - トグル: `<leader>tt` または `<leader>\``
  - 縦パネル: `<leader>tv`、フロート: `<leader>tf`
  - ターミナル内は `Esc` / `jk` でノーマルへ戻る
  - サイズは画面比率（横=30%/縦=40%）で自動決定

---

### 8) Treesitter / 解析

- `:TSUpdate` でパーサ更新
- `nvim-treesitter-context` は上部に現在の関数/ブロックを表示
  - トグル: `<leader>ct`、上位へジャンプ: `[c`

---

### 9) Git 連携

- 変更行: `gitsigns.nvim`
- UI 操作: `:Neogit`
- 差分/履歴: `:DiffviewOpen`（閉じる `:DiffviewClose`）
- 低レベル操作: `:G`（vim-fugitive）

---

### 10) よくある操作（抜粋）

- Explorer: `Ctrl-b` でトグル（Neo-tree）
- 検索: `Ctrl-p`（ファイル）、`<leader>fg`（ripgrep）
- コメント: `gcc`（行）/ 選択して `gc`
- ダッシュボード再表示: `<leader>dd`

---

### 11) 設定のリロード/更新

- `:Lazy sync`（プラグインの同期・更新）
- `:source ~/.config/nvim/init.lua`（設定の再読み込み）
- 不調時は `:checkhealth` を参照

