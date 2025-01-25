#!/bin/sh

for ip in `curl -sw '\n' https://www.cloudflare.com/ips-v{4,6}`; do ufw allow from $ip to any port 8443 comment 'Cloudflare'; done

ufw reload > /dev/null 2>&1
