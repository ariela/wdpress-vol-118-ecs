# WEB+DB PRESS Vol.118 連載：即効AWSテクニック 第2回 ECS＋Fargateで実現するコンテナによる安全・確実なデプロイ 各種スクリプト

## application ディレクトリ

`Laravel`のアプリケーションです。実行テスト用のため、インストール直後の状態となっています。

## copilot ディレクトリ

### 使用方法

`AWS Copilot`のプロジェクトファイルです。下記コマンドで環境構築を行う事ができます。

```
$ cd copilot
$ copilot init -a wdpress118 -t "Load Balanced Web Service" -s web --port 80 -d ../Dockerfile.php-fpm
$ copilot env init --name production
$ copilot deploy 
```

環境を削除する場合は下記コマンドを実行します。

```
$ copilot svc delete -e production -n web
$ copilot env delete -n production
$ copilot app delete
```

## docker ディレクトリ

Dockerイメージ構築時に使用する設定ファイル等です。

### 起動スクリプト

`docker/php-fpm/runner.sh` が本誌に記載したスクリプトの完全版となります。

### terraform ディレクトリ

オマケのterraformスクリプトです。本誌環境+αの環境を構築できます。

### 使用方法

```
$ cd terraform
$ terraform apply -auto-approve
```



