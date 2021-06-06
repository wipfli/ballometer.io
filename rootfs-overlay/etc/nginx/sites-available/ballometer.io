server {
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name ballometer.io www.ballometer.io;

    location / {
        try_files $uri /index.html;
    }

    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/ballometer.io/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/ballometer.io/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
    if ($host = ballometer.io) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    if ($host = www.ballometer.io) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80;
    listen [::]:80;

    server_name ballometer.io www.ballometer.io;
    return 404; # managed by Certbot
}
