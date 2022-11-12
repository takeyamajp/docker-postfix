FROM rockylinux/rockylinux:8
MAINTAINER "Hiroki Takeyama"

# openssl
RUN mkdir /ssl_certs; \
    dnf -y install openssl; \
    dnf clean all;

# postfix
RUN dnf -y install postfix cyrus-sasl-plain cyrus-sasl-md5; \
    sed -i 's/^\(inet_interfaces =\) .*/\1 all/' /etc/postfix/main.cf; \
    sed -i 's/^\(smtpd_tls_cert_file =\) .*/\1 \/ssl_certs\/cert.pem/' /etc/postfix/main.cf; \
    sed -i 's/^\(smtpd_tls_key_file =\) .*/\1 \/ssl_certs\/key.pem/' /etc/postfix/main.cf; \
    { \
    echo 'smtpd_sasl_path = smtpd'; \
    echo 'smtpd_sasl_auth_enable = yes'; \
    echo 'broken_sasl_auth_clients = yes'; \
    echo 'smtpd_sasl_security_options = noanonymous'; \
    echo 'disable_vrfy_command = yes'; \
    echo 'smtpd_helo_required = yes'; \
    echo 'smtpd_client_restrictions = permit_sasl_authenticated, reject_unknown_client_hostname'; \
    echo 'smtpd_helo_restrictions = permit_sasl_authenticated, reject_invalid_helo_hostname, reject_non_fqdn_helo_hostname, reject_unknown_helo_hostname'; \
    echo 'smtpd_sender_restrictions = reject_non_fqdn_sender, reject_unknown_sender_domain'; \
    echo 'smtpd_recipient_restrictions = permit_sasl_authenticated, reject_unauth_destination'; \
    echo 'smtpd_data_restrictions = reject_unauth_pipelining'; \
    echo 'smtpd_tls_security_level = may'; \
    echo 'smtpd_tls_received_header = yes'; \
    echo 'smtpd_tls_loglevel = 1'; \
    echo 'smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache'; \
    echo 'smtp_tls_security_level = may'; \
    echo 'smtp_tls_loglevel = 1'; \
    echo 'smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache'; \
    echo 'tls_random_source = dev:/dev/urandom'; \
    } >> /etc/postfix/main.cf; \
    { \
    echo 'pwcheck_method: auxprop'; \
    echo 'auxprop_plugin: sasldb'; \
    echo 'mech_list: PLAIN LOGIN CRAM-MD5'; \
    } > /etc/sasl2/smtpd.conf; \
    sed -i 's/^#\(submission .*\)/\1/' /etc/postfix/master.cf; \
    sed -i 's/^#\(smtps .*\)/\1/' /etc/postfix/master.cf; \
    sed -i 's/^#\(.* syslog_name=.*\)/\1/' /etc/postfix/master.cf; \
    sed -i 's/^#\(.* smtpd_sasl_auth_enable=.*\)/\1/' /etc/postfix/master.cf; \
    sed -i 's/^#\(.* smtpd_recipient_restrictions=\).*/\1permit_sasl_authenticated,reject/' /etc/postfix/master.cf; \
    sed -i 's/^#\(.* smtpd_tls_wrappermode=.*\)/\1/' /etc/postfix/master.cf; \
    newaliases; \
    dnf clean all;

# opendkim
RUN mkdir /dkim_keys; \
    dnf -y install epel-release; \
    dnf -y install opendkim opendkim-tools glibc-locale-source; \
    sed -i 's/^\(Mode\t\).*/\1s/' /etc/opendkim.conf; \
    sed -i 's/^\(SoftwareHeader\t\).*/\1no/' /etc/opendkim.conf; \
    sed -i 's/^# *\(Domain\t.*\)/\1/' /etc/opendkim.conf; \
    echo 'smtpd_milters = inet:localhost:8891' >> /etc/postfix/main.cf; \
    dnf clean all;

# rsyslog
RUN dnf -y install rsyslog; \
    sed -i 's/\(SysSock\.Use\)="off"/\1="on"/' /etc/rsyslog.conf; \
    sed -i 's/\(^module.*load.*imjournal.*\)/#\1/' /etc/rsyslog.conf; \
    sed -i 's/\(.*StateFile.*imjournal.*\)/#\1/' /etc/rsyslog.conf; \
    dnf clean all;

# supervisor
RUN dnf -y install supervisor; \
    sed -i 's/^\(nodaemon\)=false/\1=true/' /etc/supervisord.conf; \
    sed -i 's/^;\(user\)=chrism/\1=root/' /etc/supervisord.conf; \
    sed -i 's/^\(\[unix_http_server\]\)/;\1/' /etc/supervisord.conf; \
    sed -i 's/^\(file=\/run\/supervisor\/.*\)/;\1/' /etc/supervisord.conf; \
    { \
    echo '[program:postfix]'; \
    echo 'command=/usr/sbin/postfix -c /etc/postfix start'; \
    echo 'priority=4'; \
    echo 'startsecs=0'; \
    } > /etc/supervisord.d/postfix.ini; \
    { \
    echo '[program:opendkim]'; \
    echo 'command=/usr/sbin/opendkim -f -x /etc/opendkim.conf'; \
    echo 'priority=3'; \
    } > /etc/supervisord.d/opendkim.ini; \
    { \
    echo '[program:rsyslog]'; \
    echo 'command=/usr/sbin/rsyslogd -n'; \
    echo 'priority=2'; \
    } > /etc/supervisord.d/rsyslog.ini; \
    { \
    echo '[program:tail]'; \
    echo 'command=/usr/bin/tail -F /var/log/maillog'; \
    echo 'priority=1'; \
    echo 'stdout_logfile=/dev/fd/1'; \
    echo 'stdout_logfile_maxbytes=0'; \
    } > /etc/supervisord.d/tail.ini; \
    dnf clean all;

# entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime'; \
    echo 'rm -f /var/log/maillog'; \
    echo 'touch /var/log/maillog'; \
    echo 'if [ ! -e /ssl_certs/cert.pem ] || [ ! -e /ssl_certs/key.pem ]; then'; \
    echo '  openssl genrsa -out "/ssl_certs/key.pem" 2048 &>/dev/null'; \
    echo '  openssl req -new -key "/ssl_certs/key.pem" -subj "/CN=${HOSTNAME}" -out "/ssl_certs/csr.pem"'; \
    echo '  openssl x509 -req -days 36500 -in "/ssl_certs/csr.pem" -signkey "/ssl_certs/key.pem" -out "/ssl_certs/cert.pem" &>/dev/null'; \
    echo 'fi'; \
    echo 'if [ -e /etc/sasldb2 ]; then'; \
    echo '  rm -f /etc/sasldb2'; \
    echo 'fi'; \
    echo 'sed -i "s/^\(smtpd_sasl_auth_enable =\).*/\1 yes/" /etc/postfix/main.cf'; \
    echo 'if [ ${DISABLE_SMTP_AUTH_ON_PORT_25,,} = "true" ]; then'; \
    echo '  sed -i "s/^\(smtpd_sasl_auth_enable =\).*/\1 no/" /etc/postfix/main.cf'; \
    echo 'fi'; \
    echo 'echo "${AUTH_PASSWORD}" | /usr/sbin/saslpasswd2 -p -c -u ${DOMAIN_NAME} ${AUTH_USER}'; \
    echo 'chown postfix:postfix /etc/sasldb2'; \
    echo 'sed -i '\''/^# BEGIN SMTP SETTINGS$/,/^# END SMTP SETTINGS$/d'\'' /etc/postfix/main.cf'; \
    echo '{'; \
    echo 'echo "# BEGIN SMTP SETTINGS"'; \
    echo 'echo "myhostname = ${HOSTNAME}"'; \
    echo 'echo "mydomain = ${DOMAIN_NAME}"'; \
    echo 'echo "smtpd_banner = \$myhostname ESMTP"'; \
    echo 'echo "message_size_limit = ${MESSAGE_SIZE_LIMIT}"'; \
    echo 'echo "# END SMTP SETTINGS"'; \
    echo '} >> /etc/postfix/main.cf'; \
    echo 'if [ -e /etc/supervisord.d/opendkim.ini ]; then'; \
    echo '  mv /etc/supervisord.d/opendkim.ini /etc/supervisord.d/opendkim.disabled'; \
    echo 'fi'; \
    echo 'sed -i "s/^\(smtpd_milters .*\)/#\1/" /etc/postfix/main.cf'; \
    echo 'if [ ${ENABLE_DKIM,,} = "true" ]; then'; \
    echo '  mv /etc/supervisord.d/opendkim.disabled /etc/supervisord.d/opendkim.ini'; \
    echo '  sed -i "s/^#\(smtpd_milters .*\)/\1/" /etc/postfix/main.cf'; \
    echo '  sed -i "s/^\(Domain\t\).*/\1${DOMAIN_NAME}/" /etc/opendkim.conf'; \
    echo '  sed -i "s/^\(Selector\t\).*/\1${DKIM_SELECTOR}/" /etc/opendkim.conf'; \
    echo '  sed -i "s/^\(KeyFile\t\).*/\1\/dkim_keys\/${DKIM_SELECTOR}\.private/" /etc/opendkim.conf'; \
    echo '  if [ ! -e /dkim_keys/${DKIM_SELECTOR}.private ] || [ ! -e /dkim_keys/${DKIM_SELECTOR}.txt ]; then'; \
    echo '    opendkim-genkey -b ${DKIM_KEY_LENGTH} -d ${DOMAIN_NAME} -s ${DKIM_SELECTOR} -D /dkim_keys'; \
    echo '  fi'; \
    echo '  chown -R opendkim:opendkim /dkim_keys'; \
    echo '  chmod o-rwx /dkim_keys/${DKIM_SELECTOR}.private'; \
    echo '  cat /dkim_keys/${DKIM_SELECTOR}.txt'; \
    echo 'fi'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entrypoint.sh; \
    chmod +x /usr/local/bin/entrypoint.sh;

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

ENTRYPOINT ["entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
