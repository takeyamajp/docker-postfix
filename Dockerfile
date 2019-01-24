FROM centos:centos7
MAINTAINER "Hiroki Takeyama"

# postfix
RUN yum -y install postfix; \
    sed -i 's/^\(inet_interfaces =\) .*/\1 all/1' /etc/postfix/main.cf; \
    newaliases; \
    yum clean all;

# rsyslog
RUN yum -y install rsyslog; \
    sed -i 's/^\(\$SystemLogSocketName\) .*/\1 \/dev\/log/1' /etc/rsyslog.d/listen.conf; \
    sed -i 's/^\(\$ModLoad imjournal\)/#\1/1' /etc/rsyslog.conf; \
    sed -i 's/^\(\$OmitLocalLogging\) .*/\1 off/1' /etc/rsyslog.conf; \
    sed -i 's/^\(\$IMJournalStateFile .*\)/#\1/1' /etc/rsyslog.conf; \
    yum clean all;

# supervisor
RUN yum -y install epel-release; \
    yum -y --enablerepo=epel install supervisor; \
    sed -i 's/^\(nodaemon\)=false/\1=true/1' /etc/supervisord.conf; \
    sed -i '/^\[unix_http_server\]$/a username=dummy' /etc/supervisord.conf; \
    sed -i '/^\[unix_http_server\]$/a password=dummy' /etc/supervisord.conf; \
    sed -i '/^\[supervisorctl\]$/a username=dummy' /etc/supervisord.conf; \
    sed -i '/^\[supervisorctl\]$/a password=dummy' /etc/supervisord.conf; \
    { \
    echo '[program:postfix]'; \
    echo 'command=/usr/sbin/postfix -c /etc/postfix start'; \
    echo 'startsecs=0'; \
    } > /etc/supervisord.d/postfix.ini; \
    { \
    echo '[program:rsyslog]'; \
    echo 'command=/usr/sbin/rsyslogd -n'; \
    } > /etc/supervisord.d/rsyslog.ini; \
    { \
    echo '[program:tail]'; \
    echo 'command=/usr/bin/tail -f /var/log/maillog'; \
    echo 'stdout_logfile=/dev/fd/1'; \
    echo 'stdout_logfile_maxbytes=0'; \
    } > /etc/supervisord.d/tail.ini; \
    yum clean all;

# entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'rm -f /etc/localtime'; \
    echo 'ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime'; \
    echo 'rm -f /var/log/maillog'; \
    echo 'touch /var/log/maillog'; \
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

ENV HOST_NAME smtp.example.com
ENV DOMAIN_NAME example.com
ENV MESSAGE_SIZE_LIMIT 10485760

EXPOSE 25

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
