#!/bin/bash
#set -e

if [[ "$@" = *bash* ]]; then
  exec "$@"
  exit 0
fi

# set file permissions
cd /var/www/html
mkdir -p cache 
chown -R www-data:www-data /var/www 
chmod -R 755 /var/www 
chmod -R 775 cache custom modules themes data upload 
chmod 775 config_override.php 2>/dev/null

exec "$@"

