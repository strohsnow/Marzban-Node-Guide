# Marzban-Node-Guide
### Clone Repository (All)
Install git:
```
sudo apt install -y git
```
Clone the repository:
```
git clone https://github.com/strohsnow/Marzban-Node-Guide ~/Marzban-Node-Guide
```
### Install XanMod Kernel (All)
Register the PGP key:
```
wget -qO - https://dl.xanmod.org/archive.key \
  | sudo gpg --dearmor -vo /usr/share/keyrings/xanmod-archive-keyring.gpg
```
Add the repository:
```
echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' \
  | sudo tee /etc/apt/sources.list.d/xanmod-release.list
```
Check platform compatibility:
```
wget -qO - https://dl.xanmod.org/check_x86-64_psabi.sh | awk -f -
```
Install the kernel:
```
sudo apt update -y && sudo apt dist-upgrade -y && sudo apt install -y linux-xanmod-x64v3
```
Reboot to switch the kernel:
```
sudo reboot now
```
Probe all modules:
```
sudo depmod -a
```
Enable BBR:
```
sudo nano /etc/sysctl.conf
```
```
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
```
Load the settings:
```
sudo sysctl -p
```
### Install UFW (All)
Install ufw:
```
sudo apt install -y ufw
```
Deny incoming:
```
sudo ufw default deny incoming
```
Allow outgoing:
```
sudo ufw default allow outgoing
```
Allow SSH:
```
sudo ufw allow ssh comment 'SSH'
```
Allow HTTP:
```
sudo ufw allow http comment 'HTTP'
```
Allow HTTPS:
```
sudo ufw allow https comment 'HTTPS'
```
Allow API:
```
sudo ufw allow 62050,62051 comment 'Marzban Node'
```
Enable UFW:
```
sudo ufw enable
```
### Allow Cloudflare IPs (Master)
Run the script:
```
sudo bash ~/Marzban-Node-Guide/cloudflare-ufw.sh
```
Add a cron job:
```
sudo crontab -e
```
```
0 0 * * 1 /bin/bash /path/to/Marzban-Node-Guide/cloudflare-ufw.sh > /dev/null 2>&1
```
### Configure Cloudflare
Add DNS records:
```
A       @  master_ipv4  Proxied
A  master  master_ipv4  DNS Only
A    node    node_ipv4  DNS Only
```
Add Origin Rule:
```
Rule name: Marzban
Custom filter expression: Hostname  equals  yourdomain.com
Destination port: Rewrite to...  8443
```
### Issue SSL Certificates (All)
Install certbot:
```
sudo apt install python3-certbot-dns-cloudflare
```
Get Cloudflare API token to edit zone DNS:
```
https://dash.cloudflare.com/profile/api-tokens
```
Create a Cloudflare credentials file:
```
sudo nano ~/cloudflare.ini
```
```
dns_cloudflare_api_token = YOUR_API_TOKEN
```
Restrict access to the file:
```
sudo chmod 600 ~/cloudflare.ini
```
Issue a wildcard certificate:
```
sudo certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials ~/cloudflare.ini \
  -d yourdomain.com -d *.yourdomain.com \
  -n --agree-tos --no-eff-email -m your@email.com
```
### Install WARP (All)
Get WARP+ license (optional):
```
https://t.me/warpplus
```
Run the installation script:
```
cd && sudo bash <(curl -fsSL https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh) w
```
### Install Marzban (Master)
Run the installation script:
```
sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh)" @ install --database mariadb
```
Update to the latest core:
```
sudo marzban core-update
```
Copy docker-compose.yml file:
```
sudo cp ~/Marzban-Node-Guide/docker-compose-master.yml /opt/marzban/docker-compose.yml
```
Copy nginx.conf file:
```
sudo cp ~/Marzban-Node-Guide/nginx-master.conf /opt/marzban/nginx.conf
```
Adjust Nginx configuration:
```
sudo nano /opt/marzban/nginx.conf
```
https://github.com/strohsnow/Marzban-Node-Guide/blob/87daac18a909d64bd8b59b46462910e026044750/nginx-master.conf#L13
https://github.com/strohsnow/Marzban-Node-Guide/blob/87daac18a909d64bd8b59b46462910e026044750/nginx-master.conf#L57
https://github.com/strohsnow/Marzban-Node-Guide/blob/87daac18a909d64bd8b59b46462910e026044750/nginx-master.conf#L59
https://github.com/strohsnow/Marzban-Node-Guide/blob/87daac18a909d64bd8b59b46462910e026044750/nginx-master.conf#L85-L86
https://github.com/strohsnow/Marzban-Node-Guide/blob/87daac18a909d64bd8b59b46462910e026044750/nginx-master.conf#L100
Adjust Marzban environment variables:
```
sudo nano /opt/marzban/.env
```
```
UVICORN_HOST = "127.0.0.1"
UVICORN_PORT = 8000
DASHBOARD_PATH = "/SECRET_DASHBOARD_PATH/"
XRAY_JSON = "/var/lib/marzban/xray_config.json"
XRAY_SUBSCRIPTION_URL_PREFIX = "https://yourdomain.com"
XRAY_EXECUTABLE_PATH = "/var/lib/marzban/xray-core/xray"
XRAY_ASSETS_PATH = "/var/lib/marzban/xray-core"
```
### Configure Xray (Master)
Copy xray_config.json file:
```
sudo cp ~/Marzban-Node-Guide/xray_config.json /var/lib/marzban/xray_config.json
```
Generate Xray keys for each node:
```
sudo /var/lib/marzban/xray-core/xray x25519
```
Adjust Xray configuration:
```
sudo nano /var/lib/marzban/xray_config.json
```
https://github.com/strohsnow/Marzban-Node-Guide/blob/87daac18a909d64bd8b59b46462910e026044750/xray_config.json#L34
https://github.com/strohsnow/Marzban-Node-Guide/blob/87daac18a909d64bd8b59b46462910e026044750/xray_config.json#L36
https://github.com/strohsnow/Marzban-Node-Guide/blob/87daac18a909d64bd8b59b46462910e026044750/xray_config.json#L71
https://github.com/strohsnow/Marzban-Node-Guide/blob/87daac18a909d64bd8b59b46462910e026044750/xray_config.json#L73
### Configure Marzban (Master)
Restart Marzban:
```
sudo marzban restart
```
Add dashboard admin user:
```
sudo marzban cli admin create --sudo
```
Log into the dashboard:
```
https://yourdomain.com/SECRET_DASHBOARD_PATH
```
Adjust host settings:
```
Host: reality-master
Address: master_ipv4
Port: 443

Host: reality-node
Address: node_ipv4
Port: 443
```
Adjust node settings:
```
Add New Marzban Node
Name: Marzban-Node
Address: node_ipv4
```
### Install Marzban Node (Nodes)
Run the installation script:
```
sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban-node.sh)" @ install
```
Update to the latest core:
```
sudo marzban-node core-update
```
Copy docker-compose.yml file:
```
sudo cp ~/Marzban-Node-Guide/docker-compose-node.yml /opt/marzban-node/docker-compose.yml
```
Copy nginx.conf file:
```
sudo cp ~/Marzban-Node-Guide/nginx-node.conf /opt/marzban-node/nginx.conf
```
Adjust Nginx configuration:
```
sudo nano /opt/marzban-node/nginx.conf
```
https://github.com/strohsnow/Marzban-Node-Guide/blob/87daac18a909d64bd8b59b46462910e026044750/nginx-node.conf#L13
https://github.com/strohsnow/Marzban-Node-Guide/blob/87daac18a909d64bd8b59b46462910e026044750/nginx-node.conf#L66-L67
https://github.com/strohsnow/Marzban-Node-Guide/blob/87daac18a909d64bd8b59b46462910e026044750/nginx-node.conf#L81
Restart Marzban Node:
```
sudo marzban-node restart
```
