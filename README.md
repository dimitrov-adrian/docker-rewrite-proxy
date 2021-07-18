> DISCLAIMER: This image is aimed for testing environments, it is discouraged to use in production environments, or at least with the default settings.
> For production purposes go with [traefik](https://traefik.io/)

## Default Proxy Rule

By default, every domain will be proxied by its SLD to a container resolved by this name (could be compose servise name or hostname). For development needs, it is good and ease practice to use .localhost as most of the browsers already handles it and resolving it to _127.0.0.1_

Technically the rule is:

```apache
RewriteCond %{HTTP_HOST} "^(?:.*\.)?(.*)\.[a-zA-Z0-9]+(?::\d+)?$"
RewriteRule .* "http://%1%{REQUEST_URI}" [P,QSA,L]
```

Which handles next examples as:

`example.localhost` -> `example`

`sub2.sub1.example.localhost` -> `example`

`sub2.sub1.example2com.com` -> `example2com`

## Supported Protocols:

-   HTTP (http, https)
-   WebSocket (ws, wss)
-   FastCGI (fcgi)
-   SCGI (scgi)
-   AJP (ajp)
-   FTP (ftp)

## Environment Variables

-   `REWRITE_<PRIORITY>` Add proxy rewrite rule from environment variables. \
    Format: `<destination> <hostname regex pattern>`.

-   `REWRITE_9000` Presets **default proxy rule** with priority 9000 \
    (defaults to `%1 (?:.*\.)?(.*)\.[a-zA-Z0-9]+`)\
    _you can disable it by set to empty_

-   `TZ` - Set time zone (defaults to `UTC`)

-   `APACHE_TIMEOUT` Sets the apache's timeout (defaults to `60`)

-   `SERVER_INFO_ENDPOINT` Set endpoint for apache's mod_info, or disable if empty (disabled by default) **leadslash is required**

-   `SERVER_STATUS_ENDPOINT` Set endpoint for apache's mod_status, or disable if empty (disabled by default) **leadslash is required**

-   `ENABLE_JSON_LOG` Enables JSON output of the container (defaults disabled)

## Docker Compose Example

Take in mind that the proxy container must see target containers in the network. You could use user defined networks and network aliases for that purpose.

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
            SERVER_INFO_ENDPOINT: "/.server/info"
            SERVER_STATUS_ENDPOINT: "/.server/status"
            ENABLE_JSON_LOG: 1

            REWRITE_1: 'blog wp\d+\.example\.com'
            REWRITE_2: 'blog vlog\.example\.com'
            REWRITE_100: 'image .*img\.example.com'
            REWRITE_101: 'image cdn\.example.com'
            REWRITE_900: "blog .*"
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

You could download [mkcert](https://github.com/FiloSottile/mkcert/releases) and generate own certificate and install on your system.

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

### How the self-signed certificates are generated then?

It is used the same method with mkcert, and the exact command used is:

```bash
mkcert \
    -cert-file rootfs/var/www/ssl/localhost.pem \
    -key-file rootfs/var/www/ssl/localhost.key \
    'localhost' '*.localhost' '*.local' '*.loc' '*.dock' '*.docker' '127.0.0.1' '::1'
```

### Why this container?

There is plenty of other options (traefik, caddy, ... etc.), but I found this way, the most ease to setup for my needs. All of the most popular alternatives are probably more performant for production needs, but for local dev environment I do not need most CPU/MEM performant, but something that will save me a time, and potentialy for other people too.

Since the Apache is one of the most used web servers, most of webdevs area already aware of mod_rewrite, so will be ease to use and modify with no learning curve.
