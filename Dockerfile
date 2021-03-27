FROM php:7.4-fpm

ENV WORKDIR /www

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
    libssl-dev \
    libzip-dev \
    libmemcached-dev \
    libpq-dev \
    librabbitmq-dev \
    libgmp-dev \
    zip \
    unzip \
    git \
    nginx \
    supervisor \
&& rm -rf /var/lib/apt/lists/* \
&& rm /etc/nginx/sites-enabled/*

# install php extensions
RUN docker-php-ext-configure zip\
&& docker-php-ext-configure gmp \
&& docker-php-ext-install \
zip bcmath sockets pdo pdo_pgsql pdo_mysql gmp \
&& pecl install xdebug-2.9.8 mongodb-1.9.0 amqp-1.9.4 redis-5.3.3 \
&& docker-php-ext-enable xdebug mongodb amqp redis

# install composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/local/bin --filename=composer --version=2.0.8 --quiet

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