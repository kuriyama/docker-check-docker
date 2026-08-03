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
2. `--pull --no-cache` で candidate イメージをビルドし、常に最新の `alpine:3.23` ベースおよび最新の `docker-cli` / `check-docker` を取得する。
3. candidate と Docker Hub 上の既存 `latest` それぞれから `image-packages.txt` を取り出して比較する。
   - パッケージ一覧が同一なら push しない（イメージのビルド日時などメタデータだけの差分は無視される）。
   - 一覧に差分がある場合、または `latest` が未公開の場合のみ `latest` と `${GITHUB_SHA}` タグを push する。

### 必要な GitHub 設定

リポジトリの Settings → Secrets and variables → Actions に以下を登録する。

| 種類 | 名前 | 内容 |
|---|---|---|
| Variable | `DOCKERHUB_USERNAME` | Docker Hub ユーザー名 |
| Secret | `DOCKERHUB_TOKEN` | Docker Hub Personal Access Token（アカウントパスワードは使わない） |
