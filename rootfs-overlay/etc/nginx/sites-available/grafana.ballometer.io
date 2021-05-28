server {
    listen 80;
    listen [::]:80;

    server_name grafana.ballometer.io;

    location / {
        proxy_pass http://localhost:3004/;
    }
}
