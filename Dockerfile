FROM centos
MAINTAINER "Hiroki Takeyama"

# postfix
RUN yum -y install postfix; yum clean all; \
    sed -i 's/^inet_interfaces = .*$/inet_interfaces = all/1' /etc/postfix/main.cf;

# entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'rm -f /etc/localtime'; \
    echo 'ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime'; \
    echo 'sed -i '\''/^# BEGIN SETTINGS$/,/^# END SETTINGS$/d'\'' /etc/postfix/main.cf'; \
    echo '{'; \
    echo 'echo "# BEGIN SETTINGS"'; \
    echo 'echo "myhostname = ${HOST_NAME}"'; \
    echo 'echo "mydomain = ${DOMAIN}"'; \
    echo 'echo "myorigin = $mydomain"'; \
    echo 'echo "smtpd_banner = $myhostname ESMTP unknown"'; \
    echo 'echo "message_size_limit = ${MESSAGE_SIZE_LIMIT}"'; \
    echo 'echo "# END SETTINGS"'; \
    echo '} >> /etc/postfix/main.cf'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entrypoint.sh; \
    chmod +x /usr/local/bin/entrypoint.sh;
ENTRYPOINT ["entrypoint.sh"]

ENV TIMEZONE Asia/Tokyo

ENV HOST_NAME mail.example.com
ENV DOMAIN example.com
ENV MESSAGE_SIZE_LIMIT 10485760

EXPOSE 25

CMD ["postfix"]
