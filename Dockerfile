FROM php:7.3-fpm

ENV WORKDIR /www

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
    libssl-dev \
    libzip-dev \
    libmemcached-dev \
    libpq-dev \
    librabbitmq-dev \
    zip \
    unzip \
    git \
    nginx \
    supervisor \
&& rm -rf /var/lib/apt/lists/* \
&& rm /etc/nginx/sites-enabled/*

# install php extensions
RUN docker-php-ext-configure zip --with-libzip \
&& docker-php-ext-install \
zip bcmath sockets pdo pdo_pgsql pdo_mysql \
&& pecl install xdebug-2.7.1 mongodb-1.6.0 amqp-1.9.4 \
&& docker-php-ext-enable xdebug mongodb amqp

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
&& php -r "unlink('composer-setup.php');"

# PHP ini file
COPY php/conf/php.ini-production /usr/local/etc/php/php.ini
# Xdebug config
COPY php/xdebug/xdebug.config.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.config.ini
# Nginx config
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
# Supervisor config
COPY supervisor/supervisord.conf /etc/supervisord.conf

WORKDIR ${WORKDIR}
EXPOSE 80 443

CMD ["supervisord", "-n", "-c",  "/etc/supervisord.conf"]