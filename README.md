# postfix
[![Docker Stars](https://img.shields.io/docker/stars/takeyamajp/postfix.svg)](https://hub.docker.com/r/takeyamajp/postfix/)
[![Docker Pulls](https://img.shields.io/docker/pulls/takeyamajp/postfix.svg)](https://hub.docker.com/r/takeyamajp/postfix/)
[![](https://img.shields.io/badge/GitHub-Dockerfile-orange.svg)](https://github.com/takeyamajp/docker-postfix/blob/master/Dockerfile)
[![license](https://img.shields.io/github/license/takeyamajp/docker-postfix.svg)](https://github.com/takeyamajp/docker-postfix/blob/master/LICENSE)

## Image summary
    FROM centos:centos7  
    MAINTAINER "Hiroki Takeyama"
    
    ENV TIMEZONE Asia/Tokyo
    
    ENV HOST_NAME smtp.example.com  
    ENV DOMAIN_NAME example.com
    
    ENV MESSAGE_SIZE_LIMIT 10240000
    
    ENV AUTH_USER user  
    ENV AUTH_PASSWORD password
    
    EXPOSE 25  
    EXPOSE 587
    
    EXPOSE 465

## How to use
    docker run -d --name postfix \  
           -e TIMEZONE=Asia/Tokyo \  
           -e HOST_NAME=smtp.example.com \  
           -e DOMAIN_NAME=example.com \  
           -e MESSAGE_SIZE_LIMIT=10240000 \  
           -e AUTH_USER=user \  
           -e AUTH_PASSWORD=password \  
           -p 8025:25 \  
           -p 8587:587 \  
           -p 8465:465 \  
           takeyamajp/postfix 

## Timezone
You can use any time zone that can be used in CentOS such as America/Chicago.  

See below for zones.  
https://www.unicode.org/cldr/charts/latest/verify/zones/en.html

## Message size limit
Increase the value of MESSAGE_SIZE_LIMIT, if you send a mail of more than 10MB size.

## Username
The user name used at authentication will be a format like a e-mail address (e.g. user@example.com).  
It won't be included in a sent mail, so you can use any sender address according to your purpose.

## Port No.
You can usually use port 25 or 587.  
Use port 465 if your mail client needs SMTPS(SMTP over SSL), then ignore a displayed certificate warning.

## Logging
This container logs all failed and successful deliveries to 'docker logs'.

Use the following command to view the logs in real time.

    docker logs -f postfix
