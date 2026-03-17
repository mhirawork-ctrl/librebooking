#!/bin/bash

set -euo pipefail
trap 'echo "Exit status $? at line $LINENO from: $BASH_COMMAND"' ERR

apt-get update
apt-get upgrade --yes
apt-get install --yes --no-install-recommends \
  cron \
  libfreetype6-dev \
  libjpeg-dev \
  libldap-dev \
  libpng-dev \
  unzip
apt-get clean
rm -rf /var/lib/apt/lists/*

cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

cat >/etc/apache2/conf-available/remoteip.conf <<'EOF'
RemoteIPHeader X-Real-IP
RemoteIPInternalProxy 10.0.0.0/8
RemoteIPInternalProxy 172.16.0.0/12
RemoteIPInternalProxy 192.168.0.0/16
EOF

cat >/etc/apache2/conf-available/servername.conf <<'EOF'
ServerName localhost
EOF

a2enconf remoteip
a2enconf servername
a2enmod headers
a2enmod remoteip
a2enmod rewrite

docker-php-ext-configure gd --with-jpeg --with-freetype
docker-php-ext-install mysqli gd ldap
if pecl install timezonedb; then
  docker-php-ext-enable timezonedb
else
  echo "Skipping timezonedb installation because the PECL package is currently unavailable."
fi

mkdir -p /var/log/librebooking
chown -R www-data:root /var/log/librebooking
chmod -R g+rwx /var/log/librebooking

sed \
  -i /etc/apache2/ports.conf \
  -e 's/Listen 80/Listen 8080/' \
  -e 's/Listen 443/Listen 8443/'

sed \
  -i /etc/apache2/sites-available/000-default.conf \
  -e 's/<VirtualHost *:80>/<VirtualHost *:8080>/'

composer install --working-dir=/var/www/html --no-interaction

sed \
  -i /var/www/html/database_schema/create-user.sql \
  -e "s:^DROP USER ':DROP USER IF EXISTS ':g" \
  -e "s:booked_user:schedule_user:g" \
  -e "s:localhost:%:g"

mkdir -p \
  /var/www/html/tpl_c \
  /var/www/html/Web/uploads/images \
  /var/www/html/Web/uploads/reservation \
  /config

chown -R www-data:root \
  /config \
  /var/www/html/config \
  /var/www/html/plugins \
  /var/www/html/tpl_c \
  /var/www/html/Web/uploads/images \
  /var/www/html/Web/uploads/reservation \
  /usr/local/etc/php/conf.d

chmod -R g+rwx \
  /config \
  /var/www/html/config \
  /var/www/html/plugins \
  /var/www/html/tpl_c \
  /var/www/html/Web/uploads/images \
  /var/www/html/Web/uploads/reservation \
  /usr/local/etc/php/conf.d
