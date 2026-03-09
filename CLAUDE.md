# CLAUDE.md

## プロジェクト概要

Cloudflare DNS の A レコードを現在のグローバル IP で更新する DDNS スクリプト（bash）。
自宅サーバーなど動的 IP 環境向け。cron で定期実行して使う。

## 構成

- `update_record.sh` - メインスクリプト
- `ddns-cloudflare.conf` - 設定ファイルのテンプレート（実際の設定は `~/.ddns-cloudflare.conf` にコピーして使用）

## 開発ルール

- シェルスクリプトは `bash -eu` で実行（`-x` はトークン漏洩するため使用禁止）
- 変数展開は必ずダブルクォートで囲む
- JSON の構築には `jq -n --arg` を使い、文字列連結はしない
- 設定ファイルに認証情報が含まれるため、テンプレート以外の `.conf` ファイルをコミットしない
