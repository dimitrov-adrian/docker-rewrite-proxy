> DISCLAIMER: This image is aimed for testing environments, it is discouraged to use in production environments, or at
> least with the default settings. For production purposes go with [traefik](https://traefik.io/) or [caddy](https://caddyserver.com/)

## Default Proxy Rule

By default (if **not set** any `REWRITE_*`), every domain will be proxied by its SLD to a container resolved by this
name (could be compose service name or hostname). For development needs, it's a good practice to use .localhost as most
of the browsers already handles it and resolving it to `127.0.0.1`

Examples:

-   `example.localhost` -> `example`
-   `sub2.sub1.example.localhost` -> `example`
-   `sub2.sub1.example2com.com` -> `example2com`

## Supported Protocols:

-   HTTP (http, https)
-   WebSocket (ws, wss)
-   FastCGI (fcgi)

## Environment Variables

-   `REWRITE_<PRIORITY>` Add proxy rewrite rule from environment variables. \
    Format: `<destination> <hostname regex pattern>`. \
    \
    **NOTE: whenever rewrite variable is set, the default rule is disabled.**

-   `TRUSTED_PROXIES` Set apache2 remote_ip proxy list (defaults to
    `10.0.0.0/8 100.64.0.0/10 172.16.0.0/12 192.168.0.0/16 169.254.0.0/16 127.0.0.0/8`

-   `ENABLE_HTTP2` Enables http2 handler (defaults to `on`)

-   `TZ` - Set time zone (defaults to `UTC`)

-   `HOSTNAME` - Set hostname (docker builtin)

-   `APACHE_TIMEOUT` Sets the apache's timeout (defaults to `60`)

-   `APACHE_MAX_FORWARDS` Set the apache's max proxy forwards (defaults to `15`)

-   `SERVER_INFO_ENDPOINT` Set endpoint for apache's mod_info, or disable if empty (defaults to empy) **leadslash is
    required**

-   `SERVER_STATUS_ENDPOINT` Set endpoint for apache's mod_status, or disable if empty (defaults to empy) **leadslash is
    required**

-   `ENABLE_DEFLATE` Enables deflate (defaults to `on`)

-   `SERVER_ADMIN` Set server's admin email (defaults to `admin@localhost`)

-   `ENABLE_ACME` Enable apache's mod_md for auto letsencrypt ssl (defaults to disabled)

-   `ACME_DOMAINS` Space separated list of domains to issue ACME certificate

-   `ACME_AUTHORITY` Defaults authority (defaults to https://acme-v02.api.letsencrypt.org/directory)

-   `ENABLE_JSON_LOG` Enables JSON output of the container (defaults to `off`)

## Docker Compose Example

Take in mind that the proxy container must see target containers in the network. You could use user defined networks and
network aliases for that purpose.

```yaml
# docker-compose.yml

version: "2.4"

services:
    proxy:
        image: dimitrovadrian/rewrite-proxy
        ports:
            - "80:80"
            - "443:443"
        volumes:
            # Custom .htaccess for more control
            # - ./.htaccess:/var/www/proxy/.htaccess
        environment:
            TZ: GMT
            SERVER_INFO_ENDPOINT: "/.httpd/info"
            SERVER_STATUS_ENDPOINT: "/.httpd/status"
            ENABLE_JSON_LOG: 1

            # Rules container <- domain pattern
            REWRITE_1: 'blog wp\d+\.example\.com'
            REWRITE_2: 'blog vlog\.example\.com'
            REWRITE_100: 'image .*img\.example.com'
            REWRITE_101: 'http://image:80 cdn\.example.com'
            REWRITE_8999: "blog .*\.example-only.com"
            REWRITE_9000: "blog example-only.com"

            SERVER_ADMIN: 'JohnDoe@example.com'
            ENABLE_ACME: 1
            ACME_DOMAINS: 'vlog.example.com wp.example.com'
            ACME_AUTHORITY: 'https://acme-staging-v02.api.letsencrypt.org/directory'
    blog:
        image: wordpress
    images:
        image: httpd:alpine
```

Then you could do:

-   web1.localhost
-   web2.localhost
-   wp1.example.com

## FAQ

### What is inside the box?

-   Alpine
-   Apache 2.4 (mod_rewrite, mod_proxy, mod_ssl)
-   Self signed certificate for localhost

### Where is the apache's DocumentRoot?

It is `/var/www/proxy`

### How to use custom certificate

You could download and use [mkcert](https://github.com/FiloSottile/mkcert/releases), to generate your own certificate
and install them on your system.

```bash
./mkcert-v1.4.3-darwin-amd64 \
    -install \
    -cert-file=localhost.pem \
    -key-file=localhost.key \
    'example.com' 'myapp.dev' 'localhost' '127.0.0.1' '::1'
```

```yaml
# docker-compose.yml

volumes:
    - "./localhost.pem:/var/www/ssl/localhost.pem"
    - "./localhost.key:/var/www/ssl/localhost.key"
```

### But why self-signed certificate?

Because there is no certificate for localhost.

### Why this container?

There is plenty of other options (traefik, caddy, ... etc.), but I found this way, the most ease to setup for my needs.
All of the most popular alternatives are probably more performant for production needs, but for local dev environment I do not need most CPU/MEM performant, but something that will save me a time.

Since the Apache is one of the most used web servers, most of web devs are already aware of mod_rewrite, so will be ease
to use and modify with no learning curve.
