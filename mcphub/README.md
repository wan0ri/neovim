# MCPサーバー

## 概要

Neovimで使用するMCP（Multi-Channel Protocol）サーバーです。
このサーバーは、Neovimのプラグインや外部ツールがNeovimと通信するためのインターフェースを提供します。

## 導入方法

`.env`ファイルに以下の環境変数を設定してください。

```bash
GITHUB_TOKEN=`値`
CONTEXT7_API_KEY=`値`
TERRAFORM_CLOUD_TOKEN=`値`
```

## トークンやAPIキーの取得方法

- `GITHUB_TOKEN`: GitHubの設定ページからPersonal Access Tokenを生成してください。
- `CONTEXT7_API_KEY`: Context7の公式サイトからAPIキーを取得してください。
- `TERRAFORM_CLOUD_TOKEN`: Terraform Cloudのユーザ設定ページからAPIトークンを生成してください。
