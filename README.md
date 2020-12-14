# ballometer.io
How to set up a ballometer server

## digitalocean

I use a standard droplet from digitalocean for USD 5 per month. Operating system is Ubuntu. To store the map data I use a 60 GB block storage device on digitalocean for USD 6 per month.

## node and npm

```bash
apt install nodejs
apt install npm
```

## docker

```bash
apt update
apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt update
apt-cache policy docker-ce
apt install docker-ce
systemctl status docker
```

## tileserver-gl-light

```bash
cd /root
git clone https://github.com/maptiler/tileserver-gl.git
cd tileserver-gl
node publish.js --no-publish
cd light

# change in Dockerfile this
# ENTRYPOINT ["node", "/usr/src/app/", "-p", "80"]
# to 
# ENTRYPOINT ["node", "/usr/src/app/", "-p", "80", "--public_url", "https://ballometer.io/tiles/"]

docker build -t tileserver-gl-light .

# cd to where your .mbtiles file is

# run the image with

docker run --name tileserver-gl-light -d --rm -v $(pwd):/data -p 10001:80 tileserver-gl-light

# kill it with

docker stop tileserver-gl-light
```

## ufw

```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw enable
```

## nginx

```bash
apt update
apt install nginx
ufw app list
ufw allow 'Nginx HTTP'
ufw status
systemctl status nginx
```

Write this content into ```/etc/nginx/sites-available/ballometer.io```:

```
server {
    listen 80;
    listen [::]:80;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name ballometer.io www.ballometer.io;

    location / {
        try_files $uri $uri/ =404;
    }
    
    location /tiles {
        return 302 /tiles/;
    }

    location /tiles/  {
        proxy_pass    http://localhost:10001/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Add a symlink with ```ln -s /etc/nginx/sites-available/ballometer.io /etc/nginx/sites-enabled/```. 

Test the config file with ```nginx -t```. If ok, update nginx with ```nginx -s reload```.

## auth

```bash
cd /root
git clone https://github.com/wipfli/auth.git
cd auth
# write a settings.json file with secret, port = 3000, and salt rounds = 10
# write a users.json file
node index.js
```
