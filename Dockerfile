FROM php:7.4-fpm

RUN mkdir -p /root/.ssh/ && chmod 700 /root/.ssh/
COPY ./id_rsa /root/.ssh/id_rsa
RUN chmod 700 /root/.ssh/id_rsa


RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        zip \
        git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip \
    && docker-php-ext-install -j$(nproc) pcntl 


ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_VERSION 1.9.1

#https://raw.githubusercontent.com/composer/getcomposer.org/6e5e46fc7cab0015d5961f54bb39be1f4b330093/web/installer
COPY installer.php /tmp/installer.php
RUN php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
 && composer --ansi --version --no-interaction \
 && rm -f /tmp/installer.php

COPY docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /app

# set LANG=C.UTF-8
ENV LANG C.UTF-8

# change global configuration of repository
RUN composer config -g repositories.packagist composer http://ce50331.starbucks.net:8081/repository/composer-central/

ENTRYPOINT ["/bin/sh", "/docker-entrypoint.sh"]

CMD ["composer"]