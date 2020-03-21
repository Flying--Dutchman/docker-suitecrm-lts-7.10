#!/bin/bash
#set -e

# logfile=/dev/stdout

# set file permissions
# printf '%s\n' "Set permissions" > "$logfile"

echo "Set permissions"
cd /var/www/html

echo "Create cache folder if needed..."
mkdir -p cache 

echo "Set owner of /var/www to www-data..."
chown -R www-data:www-data /var/www 

echo "Set chmod of /var/www recursivly to 755"
chmod -R 755 /var/www 

echo "Set chmod of cache custom modules themes data upload recursivly to 775"
chmod -R 775 cache custom modules themes data upload 

echo "Set chmod of config_override.php to 775"
chmod 775 config_override.php 2>/dev/null

#exec gosu www-data "$@"
exec "$@"
