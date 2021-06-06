# server
How to set up a ballometer server

## digitalocean

For webhosting I use a standard droplet from [digitalocean](https://www.digitalocean.com/) (1 CPU / 2 GB Memory / 50 GB Disk + 60 GB / FRA1 - Ubuntu 21.04 (LTS) x64). The file containing the map data for the entire planet is more than 50 GB in size. This is why I use an extra 60 GB data volume.

## namecheap

I registered https://ballometer.io on [namecheap](https://namecheap) and added [A records](https://www.namecheap.com/support/knowledgebase/article.aspx/319/2237/how-can-i-set-up-an-a-address-record-for-my-domain/) for the following (sub-)domains:

* `ballometer.io`
* `www.ballometer.io`
* `api.ballometer.io`
* `tiles.ballometer.io`
* `grafana.ballometer.io`

## GitHub Secrets

Configuration details which I wanted or had to keep private are stored in [GitHub secrets](https://docs.github.com/en/actions/reference/encrypted-secrets) associated with this repository.

The ansible scripts that configure the server use ssh to access it and run in a GitHub actions workflow. The SSH private key is stored in `secrets.SSH_PRIVATE_KEY`. The IP address of the server is stored in the `secrets.HOST_IP`. 

User authentication is based on [json web tokens](https://jwt.io/). The JWT secret is stored in the `secrets.JWT_SECRET`.

I use self-hosted map data from [OpenMapTiles](https://openmaptiles.org/) and [OpenStreetMaps](https://www.openstreetmap.org). Specify in `secrets.VOLUME_PATH` where the over 50 GB of map data should be stored (e.g. `/mnt/volume_fra1_02/`). And point `secrets.MBTILES_URL` to the place from where the map data can be downloaded (e.g. `https://data.maptiler.com/download/***/maptiler-osm-2017-07-03-v3.6.1-planet.mbtiles`).

## GitHub Actions Workflow

The full server configuration is automated by [`deploy.yml`](https://github.com/ballometer/server/blob/main/.github/workflows/deploy.yml). This workflow adds the ssh keys and runs the ansible playbooks which for example [install APT packages](https://github.com/ballometer/server/blob/main/apt.yml) or [configure Nginx](https://github.com/ballometer/server/blob/main/nginx.yml). Pushes to the `main` branch trigger this workflow.

With [`deploy-frontend.yml`](https://github.com/ballometer/server/blob/main/.github/workflows/deploy-frontend.yml) I can build and deploy the [frontend](https://github.com/ballometer/frontend/) separately on a manual trigger.

## backup

You can create a backup of the data stored in influxdb and the `users.json` file with a script which runs on a separate machine. The script will ssh into your server, create the backup files of the influxdb data, and pull it to you backup machine with rsync. You can do full backups with `backup-full.sh` covering all data stored in influxdb, or you can only backup the last 48 hours of data with `backup-48h.sh`.

Create a full backup with:

```bash
git clone https://github.com/ballometer/server.git
cd server
HOST_IP=<ip-of-your-server> ./backup-full.sh
```

The data will be stored in `backup-data`.

Create a backup of the last 48 hours with
```bash
HOST_IP=<ip-of-your-server> ./backup-48h.sh
```

To restore the influxdb data and `users.json`, run:
```bash
HOST_IP=<ip-of-your-server> ./restore.sh
```

## zsh

To get a nice shell I still do the following steps by hand:

```bash
apt install zsh -y
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
sed -i '/# DISABLE_AUTO_UPDATE="true"/c\DISABLE_AUTO_UPDATE="true"' ~/.zshrc
sed -i '/plugins=(git)/c\plugins=(git zsh-autosuggestions)' ~/.zshrc
```
