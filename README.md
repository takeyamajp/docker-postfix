# postfix
Star this repository if it is useful for you.  
[![Docker Stars](https://img.shields.io/docker/stars/takeyamajp/postfix.svg)](https://hub.docker.com/r/takeyamajp/postfix/)
[![Docker Pulls](https://img.shields.io/docker/pulls/takeyamajp/postfix.svg)](https://hub.docker.com/r/takeyamajp/postfix/)
[![license](https://img.shields.io/github/license/takeyamajp/docker-postfix.svg)](https://github.com/takeyamajp/docker-postfix/blob/master/LICENSE)

`English`  
[`Japanese (日本語)`](https://github.com/takeyamajp/docker-postfix/blob/master/README.ja.md)

## Supported tags and respective Dockerfile links  
- [`latest`, `rocky8`](https://github.com/takeyamajp/docker-postfix/blob/master/rocky8/Dockerfile) (Rocky Linux)
- [`centos8`](https://github.com/takeyamajp/docker-postfix/blob/master/centos8/Dockerfile) (We have finished support to CentOS 8.)
- [`centos7`](https://github.com/takeyamajp/docker-postfix/blob/master/centos7/Dockerfile)

## Image summary
    FROM rockylinux/rockylinux:8  
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

## How to use
You can send a mail using a secure connection (SSL/TLS).  
In advance you may need to add SPF, DKIM, DMARC records to your DNS server in order that your mail avoids being marked as a spam.

### via [`docker-compose`](https://github.com/docker/compose)

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

## Time zone
You can use any time zone such as America/Chicago that can be used in Rocky Linux.  

See below for zones.  
https://www.unicode.org/cldr/charts/latest/verify/zones/en.html

## Message size limit
The maximum size in bytes of a mail you can send. (attached files included)  
Increase the value of MESSAGE_SIZE_LIMIT, if you send a mail of more than 10MB size.

## Username
The user name used at authentication will be a format like a e-mail address (e.g. user@example.com).  
It won't be included in a sent mail, so you can use any sender address according to your purpose.

## Port No.
You can usually use submission port 587.  
Use port 465 if your mail client needs SMTPS (SMTP over SSL), then ignore a displayed certificate warning.  
Port 25 is disabled by default. Set DISABLE_SMTP_AUTH_ON_PORT_25 to false If you want to use it.

## SSL certificates
The self-signed certificate will be created automatically into the volume '/ssl_certs', and it can be added to your OS (e.g. Windows, Linux, iOS, and Android) as the root certificate in order to avoid warnings on your mail clients.  
If you have a valid server certificate, replace that with yours.  

## DKIM keys
The public key will be displayed on 'docker logs'.  
Mount the volume '/dkim_keys' on your host machine. Otherwise the key will be changed every time this container starts.  
You can set DKIM_KEY_LENGTH to 2048 if your DNS server supports TXT records of more than 255 length.  
If you have a mail server besides this container, you will need to change DKIM_SELECTOR from 'default' so that it doesn't overlap with other one.

## Logging
This container logs all failed and successful deliveries to 'docker logs'.

Use the following command to view the logs in real time.

    docker logs -f postfix
