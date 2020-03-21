FROM php:7.3-apache
ARG SUITECRM_VERSION=7.10.24

COPY entrypoint.sh php.custom.ini /

RUN \
# Install packages
    apt-get update && apt-get install -y --no-install-recommends \
    cron \
	dos2unix \
	libc-client-dev \
	libcurl4-openssl-dev \
	libfreetype6-dev \
	libjpeg62-turbo-dev \
	libkrb5-dev \
	libldap2-dev \
	libmcrypt-dev \
	libpng-dev \
	libpq-dev \
	libssl-dev \
	libxml2-dev \
	libzip-dev \
	unzip \
	zlib1g-dev \
	gosu \
# Install composer
	&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
# Cleanup APT
	&& apt autoremove -y \
	&& apt clean \
	&& rm -rf /var/lib/apt/lists/* \
# Listen on non privilaged ports
	&& sed -i 's/Listen 80$/Listen 8080/g' /etc/apache2/ports.conf \
	&& sed -i 's/Listen 443$/Listen 8443/g' /etc/apache2/ports.conf \
	&& rm -rf /var/log/apache2/* \
	&& touch /var/log/apache2/access.log /var/log/apache2/error.log /var/log/apache2/other_vhosts_access.log \
	&& chown -R www-data:www-data /var/log/apache2 \
# PHP extensions
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-configure intl \
	&& docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
	&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
	&& docker-php-ext-install -j$(nproc) fileinfo gd imap ldap zip mysqli pdo_mysql pdo_pgsql soap intl \
# Setting up SuiteCRM
    && gosu www-data curl https://codeload.github.com/salesagility/SuiteCRM/zip/v${SUITECRM_VERSION} -o /tmp/master.zip \
	&& gosu www-data unzip /tmp/master.zip -d /tmp \
	&& gosu www-data mv /tmp/SuiteCRM-*/* /var/www/html \
	&& rm -rf /tmp/* \
	&& echo "* * * * * cd /var/www/html; php -f cron.php > /dev/null 2>&1 " | crontab - \
# Setting up file redirection for docker volumes
 	&& mkdir /var/www/html/docker.d \
# Log file
	&& mkdir /var/www/html/docker.d/logs \
	&& touch /var/www/html/docker.d/logs/suitecrm.log \
	&& ln -s /var/www/html/docker.d/logs/suitecrm.log /var/www/html/suitecrm.log \
# Config
	&& mkdir /var/www/html/docker.d/conf.d \
	&& touch /var/www/html/docker.d/conf.d/config.php \
	&& touch /var/www/html/docker.d/conf.d/config_override.php \
	&& ln -s /var/www/html/docker.d/conf.d/config.php /var/www/html/config.php \
	&& ln -s /var/www/html/docker.d/conf.d/config_override.php /var/www/html/config_override.php \
# Set folder rights
	&& chown -hR www-data:www-data /var/www/html \
# Update composer
	&& gosu www-data composer update --no-dev -n \
# custom php configurations
	&& mv /php.custom.ini /usr/local/etc/php/conf.d/ \
# entrypoint
	&& dos2unix /entrypoint.sh \
	&& chmod 777 /entrypoint.sh \
# Change access righs to conf, logs, bin from root to www-data
	&& chown -hR www-data:www-data /etc/apache2/ 

# Define volumes
VOLUME /var/www/html/docker.d
VOLUME /var/www/html/upload
VOLUME /var/www/html/docker.d/conf.d
VOLUME /var/www/html/docker.d/logs
VOLUME /var/www/html/custom
# Entire SuiteCRM folder (if needed)
VOLUME /var/www/html/

# Define ports
EXPOSE 8080

# Run healtcheck
HEALTHCHECK --interval=60s --timeout=30s --start-period=20s CMD curl --fail http://localhost:8080/ || exit 1

ENTRYPOINT ["/entrypoint.sh"]
