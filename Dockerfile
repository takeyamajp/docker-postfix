FROM centos
MAINTAINER "Hiroki Takeyama"

# postfix
RUN yum -y install postfix; \
    sed -i 's/^inet_interfaces = .*$/inet_interfaces = all/1' /etc/postfix/main.cf; \
    yum clean all;

# supervisor
RUN yum -y install epel-release; \
    yum -y --enablerepo=epel install supervisor; \
    sed -i 's/^nodaemon=false/nodaemon=true/1' /etc/supervisord.conf; \
    { \
    echo '[program:postfix]'; \
    echo 'process_name = master'; \
    echo 'command = postfix.sh'; \
    echo 'startsecs = 0'; \
    echo 'autorestart = false'; \
    } > /etc/supervisord.d/postfix.ini; \
    { \
    echo '#!/bin/bash -eu'; \
    echo 'trap "{ /usr/sbin/postfix stop; exit 0; }" EXIT'; \
    echo '/usr/sbin/postfix -c /etc/postfix start'; \
    echo 'sleep infinity'; \
    } > /usr/local/bin/postfix.sh; \
    chmod +x /usr/local/bin/postfix.sh; \
    yum clean all;

# entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'rm -f /etc/localtime'; \
    echo 'ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime'; \
    echo 'sed -i '\''/^# BEGIN SMTP SETTINGS$/,/^# END SMTP SETTINGS$/d'\'' /etc/postfix/main.cf'; \
    echo '{'; \
    echo 'echo "# BEGIN SMTP SETTINGS"'; \
    echo 'echo "myhostname = ${HOST_NAME}"'; \
    echo 'echo "mydomain = ${DOMAIN_NAME}"'; \
    echo 'echo "myorigin = \$mydomain"'; \
    echo 'echo "smtpd_banner = \$myhostname ESMTP unknown"'; \
    echo 'echo "message_size_limit = ${MESSAGE_SIZE_LIMIT}"'; \
    echo 'echo "# END SMTP SETTINGS"'; \
    echo '} >> /etc/postfix/main.cf'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entrypoint.sh; \
    chmod +x /usr/local/bin/entrypoint.sh;
ENTRYPOINT ["entrypoint.sh"]

ENV TIMEZONE Asia/Tokyo

ENV HOST_NAME mail.example.com
ENV DOMAIN_NAME example.com
ENV MESSAGE_SIZE_LIMIT 10485760

EXPOSE 25

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
