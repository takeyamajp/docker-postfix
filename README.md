FROM centos
MAINTAINER "Hiroki Takeyama"

ENV TIMEZONE Asia/Tokyo

ENV HOST_NAME mail.example.com  
ENV DOMAIN example.com  
ENV MESSAGE_SIZE_LIMIT 10485760

EXPOSE 25
