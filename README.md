# postfix
[![Docker Stars](https://img.shields.io/docker/stars/takeyamajp/postfix.svg?style=flat-square)](https://hub.docker.com/r/takeyamajp/postfix/)
[![Docker Pulls](https://img.shields.io/docker/pulls/takeyamajp/postfix.svg?style=flat-square)](https://hub.docker.com/r/takeyamajp/postfix/)
[![license](https://img.shields.io/github/license/u6k/plantuml-image-generator.svg)](https://github.com/u6k/plantuml-image-generator/blob/master/LICENSE)

FROM centos  
MAINTAINER "Hiroki Takeyama"

ENV TIMEZONE Asia/Tokyo

ENV HOST_NAME mail.example.com  
ENV DOMAIN example.com  
ENV MESSAGE_SIZE_LIMIT 10485760

EXPOSE 25
