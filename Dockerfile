FROM alpine:3.17

RUN \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk add --no-cache apache2 apache2-ssl apache2-http2 apache2-proxy apache-mod-md tzdata \
    && rm -rf /var/www/localhost /etc/apache2/conf.d/* \
    && mkdir -p /var/www/proxy && chown apache:apache /var/www/proxy

ADD rootfs /

VOLUME [ "/acme" ]

EXPOSE 80/tcp 443/tcp

ENV TZ=UTC \
    APACHE_TIMEOUT=60 \
    APACHE_MAX_FORWARDS=15 \
    SERVER_ADMIN="admin@localhost" \
    SERVER_INFO_ENDPOINT= \
    SERVER_STATUS_ENDPOINT= \
    ENABLE_DEFLATE="on" \
    ENABLE_HTTP2="on" \
    ENABLE_ACME= \
    ACME_DOMAINS= \
    ACME_AUTHORITY="https://acme-v02.api.letsencrypt.org/directory" \
    STRICT_TRANSPORT_SECURITY="max-age=0" \
    TRUSTED_PROXIES="10.0.0.0/8 100.64.0.0/10 172.16.0.0/12 192.168.0.0/16 169.254.0.0/16 127.0.0.0/8"

CMD ["sh", "/docker-entrypoint.sh"]
