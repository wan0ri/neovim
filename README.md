# Neovim VSCode-like Starter（Infra）

この設定は VSCode に近い操作感で、Terraform / YAML / Docker などのインフラ作業を快適にします。まずは下の「基本操作」だけ押さえれば使い始められます。詳細は分割ドキュメントを参照してください。

---

## 基本操作（最初に使うもの）

- リーダーキー: `<Space>`（以降の `<leader>` はスペース）
- ファイル検索: `Ctrl-p` / `<leader>ff`
- プロジェクト内検索: `<leader>fg`
- エクスプローラ: `Ctrl-b`
- フォーマット: `<leader>f`（保存時も自動）
- ターミナル（下パネル）: `<leader>tt` / `<leader>\``（トグル）
- ダッシュボード: `<leader>dd`

---

## ドキュメント

- Settings: 設定・導入・運用の詳細 → `Settings.md`
- Plugins: 主なプラグインとコマンド → `Plugins.md`
- Keybindings: 主要キーバインドとカテゴリ別一覧 → `Keybindings.md`
- Troubleshooting: 困ったとき → `Troubleshooting.md`

---

## 前提環境（抜粋）

- Neovim 0.9+、git、ripgrep、make（fzf拡張のビルド用）
- Nerd Font（例: MesloLGS NF）

---

## 設定ファイルの場所

- すべてこのディレクトリ配下
  - `~/.config/nvim/init.lua`（メイン設定）
  - `~/.config/nvim/*.md`（このドキュメント群）
