# Neovim VSCode-like Starter (Infra Focus)
=======================================

この構成は VSCode に近い操作感で、Terraform / YAML / Docker などのインフラ用途を快適にする最小セットです。

---

## 構成ファイル

- `~/.config/nvim/init.lua`（本リポの `nvim-proposed/init.lua` を配置済み）

---

## 前提

- Neovim 0.9+、git、ripgrep、make（任意: Telescope FZF拡張のビルド用）
- Nerd Font（MesloLGS NF 等）

---

## 初回セットアップ（3分）

- `nvim` を起動すると `lazy.nvim` が自動でプラグインを取得します。
- `:Mason` を開き、以下をインストール（必要に応じて）
  - LSP: terraform-ls, yaml-language-server, json-lsp, dockerfile-language-server, bash-language-server, lua-language-server, helm-ls, marksman
  - Formatter: yamlfmt, prettierd or prettier, shfmt, stylua（terraform_fmt は内蔵）
  - Linter: markdownlint, yamllint

---

##キーバインド（主要）

- リーダーキー: `<Space>`
- ファイルを開く（Quick Open）: `Ctrl-p`
- コマンドパレット: `<Space> sp`
- エクスプローラ（Neo-tree）: `Ctrl-b`
- 検索（ripgrep）: `<Space> fg`
- バッファ一覧: `<Space> fb`
- コメントトグル: `gcc`（行）/ `gc`（選択）
- フォーマット（手動）: `<Space> f`
- Git UI: `:Neogit` / 差分ビュー `:DiffviewOpen`

---

## LSP アクション（バッファローカル）

- 定義へ: `gd`
- 参照を探す: `gr`
- Hover: `K`
- リネーム: `<Space> rn`
- コードアクション: `<Space> ca`
- 診断を前後へ: `[d` / `]d`
- ライン診断: `<Space> e`

---

## フォーマット/リンタ

- 保存時フォーマット有効（Conform）
- 対応: Terraform（terraform_fmt）、YAML（yamlfmt/Prettier）、JSON/JSONC（Prettier）、Lua（stylua）、Shell（shfmt）、Markdown（Prettier）
- 手動: `<Space> f`
- Lint（nvim-lint）: Markdown → markdownlint、YAML → yamllint（保存/挿入終了時に実行）

---

## Markdown

- 表編集: `:TableModeToggle`
- プレビュー: `:Glow`（終了は `q`）

---

## Terraform

- LSP: terraform-ls（`*.tf`, `*.tfvars`）
- フォーマット: 保存時に `terraform fmt`（Conform 経由）

---

## YAML / JSON

- SchemaStore 連携で自動スキーマ解決（GitHub Actions/Kubernetes 等）
- YAML LSP でキー順固定を無効化（`keyOrdering = false`）

---

## VSCode 風ショートカット（任意）

- 端末では macOS の `Cmd` は直接届かないため、WezTerm 側で中継すると快適です。
  - `SUPER+p` → `<C-p>`（Quick Open）
  - `SUPER+b` → `<C-b>`（Explorer）
  - `SUPER+SHIFT+p` → `:Telescope commands<CR>`（コマンドパレット）
  - `SUPER+/` → `<C-/>`（コメントトグル）

---

## トラブルシュート

- `:Lazy sync` でプラグイン同期 / `:checkhealth` で診断
- Mason でツールを入れたのに見つからない → `:Mason` の Path を確認、`PATH` に `$HOME/.local/share/nvim/mason/bin` を追加
- Telescope が重い → `telescope-fzf-native` をビルド、`ripgrep` の導入を確認

---

## アンインストール/元に戻す
- `rm -rf ~/.config/nvim`（設定）
- `rm -rf ~/.local/share/nvim`（プラグイン/キャッシュ。必要なら）

---

## 構成の編集場所

- `~/.config/nvim/init.lua`

