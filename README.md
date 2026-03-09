# ddns-cloudflare

自宅サーバーなど動的 IP アドレス環境向けの Dynamic DNS スクリプトです。
現在のグローバル IP アドレスを取得し、Cloudflare で管理している DNS の A レコードを更新します。

cron 等で定期実行することで、IP アドレスが変わっても常に最新の IP を DNS に反映できます。

## 必要なもの

- bash
- curl
- jq
- Cloudflare アカウントと API トークン

## セットアップ

1. 設定ファイルのテンプレートをコピーして編集します。

```bash
cp ddns-cloudflare.conf ~/.ddns-cloudflare.conf
chmod 600 ~/.ddns-cloudflare.conf
```

2. `~/.ddns-cloudflare.conf` を編集し、以下を設定してください。

| 変数 | 説明 |
|------|------|
| `AUTH_EMAIL` | Cloudflare アカウントのメールアドレス |
| `API_TOKEN` | Cloudflare API トークン |
| `DOMAIN_NAME` | 対象ドメイン（例: `example.com`） |
| `HOST_NAME` | 更新するホスト名（例: `www.example.com`） |
| `LOGGER` | ログ出力コマンド（デフォルト: `echo`） |

`ZONE_ID` と `RECORD_ID` は設定ファイル内で Cloudflare API から自動取得されます。

## 使い方

```bash
# デフォルトの設定ファイル (~/.ddns-cloudflare.conf) を使用
./update_record.sh

# 設定ファイルを指定
./update_record.sh /path/to/your-config.conf
```

### cron での定期実行例

5 分ごとに実行する場合:

```cron
*/5 * * * * /path/to/update_record.sh
```

## 仕組み

1. 設定ファイルを読み込み、外部サービス（`https://checkip.amazonaws.com/`）から現在のグローバル IP を取得
2. Cloudflare API でドメインの Zone ID と DNS レコード ID を取得
3. 取得した IP アドレスで A レコードを PATCH リクエストで更新

## ライセンス

MIT
