# Neovim VSCode-like Starter（Infra）

この設定は VSCode に近い操作感で、Terraform / YAML / Docker などのインフラ作業を快適にします。まずは下の「基本操作」だけ押さえれば使い始められます。詳細は分割ドキュメントを参照してください。

---

## 基本操作（最初に使うもの）

- リーダーキー: `<Space>`（以降の `<leader>` はスペース）
- ファイル検索: `Ctrl-p` / `<leader>ff`
- プロジェクト内検索: `<leader>fg`
- エクスプローラ: `Ctrl-b`
- フォーマット: `<leader>f`（保存時も自動）
- ターミナル（下パネル）: `<leader>tt` / `&lt;leader&gt;`+バッククォートキー（トグル）
- ダッシュボード: `<leader>dd`

---

## ドキュメント

- Settings: 設定・導入・運用の詳細 → `Settings.md`
- Plugins: 主なプラグインとコマンド → `Plugins.md`
- Keybindings: 主要キーバインドとカテゴリ別一覧 → `Keybindings.md`
- Troubleshooting: 困ったとき → `Troubleshooting.md`

---

## 前提環境（抜粋）

- Neovim 0.9+、git、ripgrep、make（fzf 拡張のビルド用）
- Nerd Font（例: MesloLGS NF）

---

## 設定ファイルの場所

- すべてこのディレクトリ配下
  - `~/.config/nvim/init.lua`（メイン設定）
  - `~/.config/nvim/*.md`（このドキュメント群）

---

## MCP サーバー連携（Codex TUI 統合）

この構成は Model Context Protocol（MCP）対応のクライアントとして、Codex CLI を Neovim 内フロートで起動し、複数の MCP サーバーをまとめて扱います。

**構成の要点**

- MCP クライアント: Codex CLI（TUI）を Neovim から起動
  - 起動キー: `<leader>ac`（トグル）
  - TUI 内で `:config reload` を実行すると `servers.json` の変更が反映されます
- サーバー定義: `~/.config/nvim/mcphub/servers.json`
- シークレット: `~/.config/nvim/mcphub/.env`（`.env.example` から作成）
- 便利コマンド/キー
  - `.env` 再読込: `:McpEnvReload` または Neovim 再起動
  - `servers.json` を開く: `<leader>as`

**同梱のサーバー定義（servers.json）**

- `filesystem`: `npx -y @modelcontextprotocol/server-filesystem`
  - 参照許可は環境変数 `ALLOW`（例: `/Users/wan0ri`）で指定
- `github`: `npx -y @modelcontextprotocol/server-github`
- `playwright`: `npx -y @executeautomation/playwright-mcp-server`（`HEADLESS=1` 推奨）
- `terraform`: `docker run --rm -i hashicorp/terraform-mcp-server:0.3.0`
  - コンテナへ `-e TFE_TOKEN` と `-e TF_TOKEN_app_terraform_io` を渡す設定
- `~/.config/nvim/mcphub/.env` の `TERRAFORM_CLOUD_TOKEN` を Neovim 側で前記2変数へエイリアス設定
- `context7`: `npx -y @upstash/context7-mcp`

**初期セットアップ手順**

1. `.env` を作成
   - `cp ~/.config/nvim/mcphub/.env.example ~/.config/nvim/mcphub/.env`
   - 必要値を追記
     - `GITHUB_TOKEN=...`
     - `CONTEXT7_API_KEY=...`
     - （任意）`TERRAFORM_CLOUD_TOKEN=...`
   - 推奨: `chmod 600 ~/.config/nvim/mcphub/.env`
2. Neovim で反映
   - `:McpEnvReload` または再起動
3. Codex TUI を開き反映確認
   - `<leader>ac` で起動 → `:config reload`
   - 5 サーバー（filesystem / github / playwright / context7 / terraform）が列挙されればOK

**トラブルシュート（単体起動テスト）**
次のコマンドはサーバーが stdio で待受に入るかを確認するためのものです。終了は `Ctrl-C`。

```bash
# .env を環境にロード（zsh/bash）
set -a; . "$HOME/.config/nvim/mcphub/.env" 2>/dev/null || true; set +a

# Filesystem
npx -y @modelcontextprotocol/server-filesystem

# GitHub（トークン必要）
npx -y @modelcontextprotocol/server-github

# Playwright（初回は依存取得で数十秒かかることあり）
HEADLESS=1 npx -y @executeautomation/playwright-mcp-server

# Context7（CONTEXT7_API_KEY 必須）
npx -y @upstash/context7-mcp

# Terraform（TFC/TFE 連携。トークンが必要）
docker run --rm -i \
  -e TFE_TOKEN \
  -e TF_TOKEN_app_terraform_io \
  hashicorp/terraform-mcp-server:0.3.0
```

補足:

- `TERRAFORM_CLOUD_TOKEN` を `.env` に設定すると、`init.lua` 側で `TFE_TOKEN` と `TF_TOKEN_app_terraform_io` が自動で同値にエイリアスされます。
- 一部クライアントは環境変数 `MCP_SERVERS_PATH` でサーバー定義ファイルを指示できます（例: `~/.config/nvim/mcphub/servers.json`）。未対応でも悪影響はありません。

**セキュリティ運用**

- `.env` はホーム配下に置き、権限は `600` を推奨
- トークンは最小権限・期限付きで発行し、不要になれば早めに失効
- 誤コミット防止のため、プロジェクト直下には `.env` を置かない
