# postfix
もし有用なら、このリポジトリーにスターを付けていただけると嬉しいです。  
[![Docker Stars](https://img.shields.io/docker/stars/takeyamajp/postfix.svg)](https://hub.docker.com/r/takeyamajp/postfix/)
[![Docker Pulls](https://img.shields.io/docker/pulls/takeyamajp/postfix.svg)](https://hub.docker.com/r/takeyamajp/postfix/)
[![license](https://img.shields.io/github/license/takeyamajp/docker-postfix.svg)](https://github.com/takeyamajp/docker-postfix/blob/master/LICENSE)

[`English`](https://github.com/takeyamajp/docker-postfix)  
`Japanese (日本語)`

## サポートしているタグと Dockerfile へのリンク  
- [`latest`, `rocky8`](https://github.com/takeyamajp/docker-postfix/blob/master/rocky8/Dockerfile) (Rocky Linux) [`alma8`](https://github.com/takeyamajp/docker-postfix/blob/master/alma8/Dockerfile) (AlmaLinux)
- [`centos8`](https://github.com/takeyamajp/docker-postfix/blob/master/centos8/Dockerfile) (CentOS 8 のサポートは 2021/12/31 に終了しました。）
- [`centos7`](https://github.com/takeyamajp/docker-postfix/blob/master/centos7/Dockerfile)

 ### サポートしているアーキテクチャー: ([`more info`](https://github.com/docker-library/official-images#architectures-other-than-amd64))  
 `amd64`, `arm64v8(Raspberry Pi)`

## 概要
    FROM rockylinux:8  
    MAINTAINER "Hiroki Takeyama"
    
    ENV TIMEZONE Asia/Tokyo
    
    ENV HOSTNAME smtp.example.com  
    ENV DOMAIN_NAME example.com
    
    ENV MESSAGE_SIZE_LIMIT 10240000
    
    ENV AUTH_USER user  
    ENV AUTH_PASSWORD password
    
    ENV DISABLE_SMTP_AUTH_ON_PORT_25 true
    
    ENV ENABLE_DKIM true  
    ENV DKIM_KEY_LENGTH 1024  
    ENV DKIM_SELECTOR default
    
    # SSL Certificates  
    VOLUME /ssl_certs
    # DKIM Keys  
    VOLUME /dkim_keys
    
    # SMTP  
    EXPOSE 25  
    # Submission  
    EXPOSE 587  
    # SMTPS  
    EXPOSE 465

## 使い方
このコンテナでは、セキュリティの高い接続 (SSL/TLS) を使ってメールを送信することが出来ます。  
送信するメールがスパムと判断されないように、事前に DNS サーバーに SPF, DKIM, DMARC レコードを追加しておいてください。

### 起動方法：[`docker-compose`](https://github.com/docker/compose)

    version: '3'  
    services:  
      postfix:  
        image: takeyamajp/postfix  
        ports:  
          - "8025:25"  
          - "8587:587"  
          - "8465:465"  
        volumes:  
          - /my/own/certs:/ssl_certs  
          - /my/own/keys:/dkim_keys  
        environment:  
          TIMEZONE: "Asia/Tokyo"  
          HOSTNAME: "smtp.example.com"  
          DOMAIN_NAME: "example.com"  
          MESSAGE_SIZE_LIMIT: "10240000"  
          AUTH_USER: "user"  
          AUTH_PASSWORD: "password"  
          DISABLE_SMTP_AUTH_ON_PORT_25: "true"  
          ENABLE_DKIM: "true"  
          DKIM_KEY_LENGTH: "1024"  
          DKIM_SELECTOR: "default"

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

## SSL証明書
自己署名証明書がボリューム '/ssl_certs' の中に自動的に作成されます。  
そして、それはメールクライアントで発生する警告を防ぐために、あなたの OS (例えば Windows, Linux, iOS, Android など) にルート証明書として追加することができます。  

有効なサーバー証明書を持っている場合は、それらを使用する事ができます。  
もし中間証明書がある場合は、以下のようにサーバー証明書の後に追加してください。  

    cat server_cert.pem intermediate_CA.pem > cert.pem

## DKIMキー
公開鍵は 'docker logs' に表示されます.  
ボリューム '/dkim_keys' をホストマシンにマウントしてください。そうしないと、このコンテナが起動するたびにDKIMの鍵が変更されてしまいます。  
もし DNS サーバーが255文字より長い TXT レコードをサポートしている場合は、DKIM_KEY_LENGTH の値を 2048 に変更する事ができます。  
あなたがこのコンテナ以外にもメールサーバーを持っている場合、セレクタが重複しないように DKIM_SELECTOR を 'default' 以外に変更してください。

## 動作ログ
このコンテナは、全てのメール送信結果を 'docker logs' に出力します。

以下のコマンドでリアルタイムにログを参照することができます。

    docker logs -f postfix
