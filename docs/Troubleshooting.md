# Troubleshooting

よくある問題と対処法のメモです。

---

## プラグインが入らない/更新されない

- `:Lazy sync` を実行し、エラーがないか確認
- ネットワーク制限がある環境では `git` のプロキシ設定を再確認

---

## アイコンが豆腐になる（□ で表示）

- Nerd Font（例: MesloLGS NF）をターミナルに適用
- `nvim-web-devicons` は自動で有効化されます

---

## Telescope が重い/検索できない

- `ripgrep` の導入を確認（`rg --version`）
- `telescope-fzf-native` をビルド（`:Lazy build telescope-fzf-native.nvim`）

---

## LSP が動かない / フォーマットできない

- `:Mason` で対象のサーバー/ツールがインストール済みかを確認
- `PATH` に `$HOME/.local/share/nvim/mason/bin` が通っているか確認
- `:checkhealth` のレポートを参照

---

## ダッシュボードや Neo-tree 上に余計な線が出る

- `indent-blankline` などの可視化系が有効になっていないか確認（本設定では除外済み）

---

## 何かおかしくなった

- 設定再読み込み: `:source ~/.config/nvim/init.lua`
- それでもダメなら `~/.local/share/nvim` のキャッシュ削除を検討（注意）
