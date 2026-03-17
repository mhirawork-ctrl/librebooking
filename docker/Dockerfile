ARG VERSION_PHP=8.3
ARG VERSION_COMPOSER=lts

FROM composer:${VERSION_COMPOSER} AS composer

FROM php:${VERSION_PHP}-apache

COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY docker/bin /usr/local/bin/
COPY docker/setup.sh /tmp/librebooking-setup.sh
COPY . /var/www/html/

ENV DEBIAN_FRONTEND=noninteractive

RUN bash /tmp/librebooking-setup.sh

USER www-data
WORKDIR /
VOLUME /config
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
EXPOSE 8080
