## Keybindings

主要なキーバインドをカテゴリ別にまとめています。`<leader>` はスペース（`<Space>`）です。

---

### 基本

- クリア検索ハイライト: `<Esc>`
- コメントトグル: `gcc`（行）/ ビジュアル選択後に `gc`
- 形式整形: `<leader>f`（保存時自動も有効）
- 高速スクロール: `j/k`（accelerated-jk）

---

### ファイル/検索（Telescope）

- ファイルを開く（Quick Open）: `Ctrl-p` / `<leader>ff`
- 隠しファイル/無視も含む検索: `<leader>fa`
- ripgrep 検索: `<leader>fg`
- バッファ一覧: `<leader>fb`
- コマンドパレット: `<leader>sp`

---

### エクスプローラ（Neo-tree）

- トグル: `Ctrl-b`

---

### ターミナル（toggleterm）

- 下パネルトグル: `<leader>tt` / `<leader>\``
- 縦パネル: `<leader>tv`
- フロート: `<leader>tf`
- ターミナル→ノーマル: `Esc` または `jk`

---

### 起動画面/パンくず/コンテキスト

- ダッシュボード: `<leader>dd` / `:Dashboard`
- Dropbar メニュー: `<leader>db`
- Treesitter Context トグル: `<leader>ct`
- 上位コンテキストへジャンプ: `[c`

---

### LSP（バッファローカル）

- 定義へ: `gd`
- 参照: `gr`
- Hover: `K`
- リネーム: `<leader>rn`
- コードアクション: `<leader>ca`
- 診断 前/次: `[d` / `]d`
- 行の診断: `<leader>e`

---

### Git

- Neogit: `:Neogit`
- Diffview: `:DiffviewOpen` / `:DiffviewClose`

---

### Copilot / CopilotChat

- 認証: `:Copilot auth`（初回）
- CopilotChat: `<leader>co`（Open）/ `<leader>cc`（Prompt）/ `<leader>cq`（Close）

