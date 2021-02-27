# ballometer.io
How to set up a ballometer server

## digitalocean

I use a standard droplet from digitalocean for USD 5 per month. Operating system is Ubuntu. To store the map data I use a 60 GB block storage device on digitalocean for USD 6 per month.

## zsh

```bash
apt install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# edit ~/.zshrc
# uncomment DISABLE_AUTO_UPDATE="true"
# plugins=(git zsh-autosuggestions)
```

## python

```bash
apt install python3-pandas
apt install python3-venv
```

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

## docker-compose

```bash
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
# docker-compose version 1.27.4, build 40524192
```

## tileserver-gl-light

cd to where your tiles.mbtiles (openmaptiles data) and your aviation.mbtiles (as created with https://github.com/wipfli/aviation) lives

Write a config.json file:

```json
{
  "options": {
    "maxSize": 1,
    "paths": {
      "root": "/app/node_modules/tileserver-gl-styles",
      "fonts": "fonts",
      "styles": "styles",
      "mbtiles": "/data"
    }
  },
  "styles": {
    "basic-preview": {
      "style": "basic-preview/style.json",
      "tilejson": {
        "bounds": [
          -180,
          -85.0511,
          180,
          85.0511
        ]
      }
    }
  },
  "data": {
    "v3": {
      "mbtiles": "tiles.mbtiles"
    },
    "aviation": {
      "mbtiles": "aviation.mbtiles"
    }
  }
}
```

```bash
docker run --name tileserver-gl -d --rm -v $(pwd):/data -p 127.0.0.1:10001:8080 maptiler/tileserver-gl --public_url https://ballometer.io/tiles/
```

## ufw

```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 'Nginx Full'
ufw delete allow 'Nginx HTTP'
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
        try_files $uri /index.html;
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

    location /api/auth {
        return 302 /api/auth/;
    }

    location /api/auth/ {
        proxy_pass  http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /api/upload {
        return 302 /api/upload/;
    }

    location /api/upload/ {
        proxy_pass  http://localhost:3001/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
    
    location /api/read {
        return 302 /api/read/;
    }

    location /api/read/ {
        proxy_pass  http://localhost:3002/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
    
    location /api/edit {
        return 302 /api/edit/;
    }

    location /api/edit/ {
        proxy_pass  http://localhost:3003/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
    
    location /grafana/ {
        proxy_pass http://localhost:3004/;
    }
    
    location /api/weather {
        return 302 /api/weather/;
    }

    location /api/weather/ {
        proxy_pass http://localhost:3005/;
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

## certbot

```bash
apt install certbot python3-certbot-nginx
certbot --nginx -d ballometer.io -d www.ballometer.io
```

## auth

```bash
cd /root
git clone https://github.com/wipfli/auth.git
cd auth
# write a settings.json file with secret, port = 3000, and salt rounds = 10
# write a users.json file

# test configuration with 
node index.js

# install with
systemctl enable /root/auth/auth.service
systemctl start auth
```

## upload

```bash
cd /root
git clone https://github.com/wipfli/upload.git
cd upload
# write a upload.service file with PORT=3001 and JWT secret

npm install

# install with
systemctl enable /root/upload/upload.service
systemctl start upload
```

## read

```bash
cd /root
git clone https://github.com/wipfli/read.git
cd read
# write a read.service file with PORT=3002

npm install

# install with
systemctl enable /root/read/read.service
systemctl start read
```

## edit

```bash
cd /root
git clone https://github.com/wipfli/edit.git
cd edit
# write a edit.service file with PORT=3003 and JWT secret

npm install

# install with
systemctl enable /root/edit/read.service
systemctl start edit
```

## influxdb

```bash
wget -qO- https://repos.influxdata.com/influxdb.key | apt-key add -
# run next lines in bash, not zsh
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | tee /etc/apt/sources.list.d/influxdb.list
apt update
apt install influxdb
systemctl unmask influxdb.service
systemctl start influxdb
# open influx-cli
influx
> CREATE DATABASE ballometer
> CREATE DATABASE weather
```

## online-ui

On my laptop I clone ```https://github.com/wipfli/online-ui``` and build the frontend with ```npm run build```. The build output gets uploaded to the server with:

```bash
scp -r build/* root@ballometer.io:/var/www/html
```

## grafana

```bash
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
apt update
apt install grafana
```

edit ```/etc/grafana/grafana.ini```

```ini
[server]
http_port = 3004
domain = ballometer.io
root_url = %(protocol)s://%(domain)s:%(http_port)s/grafana
serve_from_sub_path = true

[users]
allow_sign_up = false

[auth.anonymous]
# enable anonymous access
enabled = true
```

```bash
systemctl start grafana-server
systemctl status grafana-server
```


## download-sma

```bash
cd /root
git clone https://github.com/wipfli/download-sma.git
cd download-sma

# follow README.md

# install with
systemctl enable /root/download-sma/download-sma.service
systemctl start download-sma
```


## weather

```bash
cd /root
git clone https://github.com/wipfli/weather.git
cd weather
# write a weather.service file with PORT=3005, see README.md

npm install

# install with
systemctl enable /root/weather/weather.service
systemctl start weather
```
