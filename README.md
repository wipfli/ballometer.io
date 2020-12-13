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
docker build -t tileserver-gl-light .

# cd to where your .mbtiles file is

# run the image with

docker run --name tileserver-gl-light -d --rm -v $(pwd):/data -p 10001:80 tileserver-gl-light

# kill it with

docker stop tileserver-gl-light
```
