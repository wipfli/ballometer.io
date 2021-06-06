server {

    server_name grafana.ballometer.io;

    location / {
        proxy_pass http://localhost:3004/;
    }

    listen [::]:443 ssl; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/ballometer.io/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/ballometer.io/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
    if ($host = grafana.ballometer.io) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80;
    listen [::]:80;

    server_name grafana.ballometer.io;
    return 404; # managed by Certbot
}
