ARG PHP_VERSION

FROM php:${PHP_VERSION}-fpm-alpine

WORKDIR /var/www

COPY docker/php/xdebug.ini /usr/local/etc/php/conf.d

RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-install pdo pdo_mysql pcntl json posix calendar -j$(getconf _NPROCESSORS_ONLN) \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.remote_host="`/sbin/ip route|awk '/default/ { print $3 }'` >> /usr/local/etc/php/conf.d/xdebug.ini
