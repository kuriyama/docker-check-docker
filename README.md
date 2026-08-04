# docker-check-docker

`docker` CLI と [check_docker](https://pypi.org/project/check-docker/)（Nagios/NRPE 互換の Docker 監視プラグイン）を同梱した Alpine ベースのイメージ。

- ベースイメージ: `alpine:3.23`
- Alpine パッケージ: `docker-cli`
- Python パッケージ: `check-docker`（venv `/opt/check-docker` にインストール）

Docker Hub: [`kuriyama/check-docker`](https://hub.docker.com/r/kuriyama/check-docker)

## 使い方

```sh
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock kuriyama/check-docker check_docker --containers foo --status running
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock kuriyama/check-docker check_swarm --swarm
docker run --rm kuriyama/check-docker docker --version
```

`check-docker` パッケージが提供する実際のコマンドは `check_docker` と `check_swarm`（いずれもアンダースコア区切り）。

## ビルド

```sh
docker build --pull --no-cache --tag check-docker .
```

イメージ内の `/usr/local/share/image-packages.txt` に、インストール済みの apk / pip パッケージ一覧（バージョン付き）が記録される。これは CI で「有意な変更があったか」を判定するための指紋。

## GitHub Actions

`.github/workflows/docker.yml` が以下を行う。

1. デフォルトブランチへの push（`Dockerfile` / workflow 変更時）、毎日 03:17 JST の定期実行、手動実行（`workflow_dispatch`）で起動。
2. `--pull --no-cache --platform linux/amd64` で candidate イメージをビルドし、常に最新の `alpine:3.23` ベースおよび最新の `docker-cli` / `check-docker` を取得する。
3. candidate と Docker Hub 上の既存 `latest`（amd64 ランナー上なので `docker pull` は自動的に amd64 版を取得する）それぞれから `image-packages.txt` を取り出して比較する。
   - パッケージ一覧が同一なら push しない（イメージのビルド日時などメタデータだけの差分は無視される）。
   - 一覧に差分がある場合、または `latest` が未公開の場合のみ push する。
4. push 時は `docker buildx build --platform linux/amd64,linux/arm64 --push` でマルチアーキイメージを再ビルドし、`latest` と `YYYY-MM-DD-<short-sha>`（JST 日付 + commit SHA 先頭 7 桁、例: `2026-08-04-1a2b3c4`）タグを付ける。

パッケージ一覧の比較は amd64 版だけを代表として使う（簡易方針）。amd64/arm64 でパッケージ構成が食い違うケースは検出対象外。

### 必要な GitHub 設定

リポジトリの Settings → Secrets and variables → Actions に以下を登録する。

| 種類 | 名前 | 内容 |
|---|---|---|
| Variable | `DOCKERHUB_USERNAME` | Docker Hub ユーザー名 |
| Secret | `DOCKERHUB_TOKEN` | Docker Hub Personal Access Token（アカウントパスワードは使わない） |
