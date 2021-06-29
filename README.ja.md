# postfix
もし有用なら、このリポジトリーをスターしていただけると嬉しいです。  
[![Docker Stars](https://img.shields.io/docker/stars/takeyamajp/postfix.svg)](https://hub.docker.com/r/takeyamajp/postfix/)
[![Docker Pulls](https://img.shields.io/docker/pulls/takeyamajp/postfix.svg)](https://hub.docker.com/r/takeyamajp/postfix/)
[![license](https://img.shields.io/github/license/takeyamajp/docker-postfix.svg)](https://github.com/takeyamajp/docker-postfix/blob/master/LICENSE)

[`English`](https://github.com/takeyamajp/docker-postfix)  
`Japanese (日本語)`

## サポートしているタグと Dockerfile へのリンク  
- [`latest`, `rocky8`](https://github.com/takeyamajp/docker-postfix/blob/master/rocky8/Dockerfile) （Rocky Linux）
- [`centos8`](https://github.com/takeyamajp/docker-postfix/blob/master/centos8/Dockerfile) (CentOS 8 のサポートは 2021/12/31 に終了する予定です。）
- [`centos7`](https://github.com/takeyamajp/docker-postfix/blob/master/centos7/Dockerfile)

## 概要
    FROM rockylinux/rockylinux:8  
    MAINTAINER "Hiroki Takeyama"
    
    ENV TIMEZONE Asia/Tokyo
    
    ENV HOST_NAME smtp.example.com  
    ENV DOMAIN_NAME example.com
    
    ENV MESSAGE_SIZE_LIMIT 10240000
    
    ENV AUTH_USER user  
    ENV AUTH_PASSWORD password
    
    ENV DISABLE_SMTP_AUTH_ON_PORT_25 true
    
    # SMTP  
    EXPOSE 25  
    # Submission  
    EXPOSE 587  
    # SMTPS  
    EXPOSE 465

## 使い方
このコンテナでは、セキュリティの高い接続 (SSL/TLS) を使ってメールを送信することが出来ます。  
送信するメールがスパムと判断されないように、事前に DNS サーバーに SPF レコードを追加しておいてください。

    docker run -d --name postfix \  
           -e TIMEZONE=Asia/Tokyo \  
           -e HOST_NAME=smtp.example.com \  
           -e DOMAIN_NAME=example.com \  
           -e MESSAGE_SIZE_LIMIT=10240000 \  
           -e AUTH_USER=user \  
           -e AUTH_PASSWORD=password \  
           -e DISABLE_SMTP_AUTH_ON_PORT_25=true \  
           -p 8587:587 \  
           -p 8465:465 \  
           takeyamajp/postfix

## タイムゾーン
Rocky Linux で使用可能な、例えば America/Chicago のようなどんなタイムゾーンでも使用することが出来ます。

使用可能なタイムゾーン  
https://www.unicode.org/cldr/charts/latest/verify/zones/en.html

## メッセージサイズ
メール送信可能な最大バイト数です。（添付ファイルも含む）  
もし 10MB を超えるメールを送信する場合は、オプション MESSAGE_SIZE_LIMIT の値を増やしてください。

## ユーザー名
認証時に使用するユーザー名は、メールアドレスのような形式になります。（例：user@example.com）  
このユーザー名は送信するメールには含まれません。メールの送信元アドレスは目的に応じて自由にセットすることができます。

## ポート番号
通常はサブミッションポート 587 を使用してください。  
もし、SMTPS (SMTP over SSL) で接続したい場合はポート 465 を使用してください。接続時に表示される警告は無視してください。  
ポート 25 はデフォルトで無効にしています。もし使用したい場合はオプション DISABLE_SMTP_AUTH_ON_PORT_25 を false に設定してください。

## 動作ログ
このコンテナは、全てのメール送信結果を 'docker logs' に出力します。

以下のコマンドでリアルタイムにログを参照することができます。

    docker logs -f postfix
