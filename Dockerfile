FROM alpine:3.14

RUN \
    apk add --no-cache apache2 apache2-ssl apache2-proxy tzdata \
    && rm -rf /var/www/localhost /etc/apache2/conf.d/* \
    && mkdir -p /var/www/proxy && chown apache:apache /var/www/proxy

COPY --chown=apache:apache rootfs /

EXPOSE 80/tcp 443/tcp

ENV TZ=UTC \
    APACHE_TIMEOUT=60 \
    REWRITE_9000="%1 (?:.*\.)?(.*)\.[a-zA-Z0-9]+" \
    SERVER_INFO_ENDPOINT=\
    SERVER_STATUS_ENDPOINT=\
    ENABLE_JSON_LOG=

CMD ["sh", "/docker-entrypoint.sh"]
