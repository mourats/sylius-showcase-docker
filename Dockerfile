FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ARG PHP_VERSION=8.0
ARG MARIADB_MYSQL_SOCKET_DIRECTORY='/var/run/mysqld'
ENV LC_ALL=C.UTF-8

ARG MYSQL_DB=main
ARG MYSQL_USER=mysql
ARG MYSQL_PASSWORD=password
ARG DATABASE_URL=mysql://$MYSQL_USER:$MYSQL_PASSWORD@127.0.0.1:3306/$MYSQL_DB
ENV DATABASE_URL=$DATABASE_URL

# Install basic tools
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    make \
    supervisor \
    unzip \
    python2 \
    g++

# Append NODE, NGINX and PHP repositories
RUN add-apt-repository ppa:ondrej/php \
    && add-apt-repository ppa:ondrej/nginx \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash -

# Install required PHP extensions
RUN apt-get update && apt-get install -y \
    nodejs \
    nginx \
    php${PHP_VERSION} \
    php${PHP_VERSION}-apcu \
    php${PHP_VERSION}-calendar \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-ctype \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-exif \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-pdo \
    php${PHP_VERSION}-pgsql \
    php${PHP_VERSION}-sqlite \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-xsl \
    php${PHP_VERSION}-yaml \
    php${PHP_VERSION}-zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename composer

# Install mariadb
RUN groupadd -r mysql && useradd -r -g mysql mysql
RUN apt-get update && apt-get install -y mariadb-server mariadb-client
RUN mkdir -p $MARIADB_MYSQL_SOCKET_DIRECTORY && \
    chown root:mysql $MARIADB_MYSQL_SOCKET_DIRECTORY && \
    chmod 774 $MARIADB_MYSQL_SOCKET_DIRECTORY

# Cleanup
RUN apt-get remove --purge -y software-properties-common curl && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

# Create directory for php-fpm socket
# Link php-fpm binary file without version
# -p Creates missing intermediate path name directories
RUN ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm && mkdir -p /run/php

# Install yarn
RUN npm install -g yarn && npm cache clean --force

# Initialize config files
COPY .docker/supervisord.conf   /etc/supervisor/conf.d/supervisor.conf
COPY .docker/nginx.conf         /etc/nginx/nginx.conf
COPY .docker/fpm.conf           /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
COPY .docker/php.ini            /etc/php/${PHP_VERSION}/fpm/php.ini
COPY .docker/php.ini            /etc/php/${PHP_VERSION}/cli/php.ini

WORKDIR /app

RUN service mysql start \
    && mysql -u root -e "CREATE DATABASE ${MYSQL_DB};" \
    && export mysqlPassword=$(mysql -NBe "select password('${MYSQL_PASSWORD}');") \
    && mysql -u root -e "CREATE USER ${MYSQL_USER}@localhost IDENTIFIED BY PASSWORD '${mysqlPassword}';" \
    && mysql -u root -e "GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO '${MYSQL_USER}'@'localhost';" \
    && mysql -u root -e "FLUSH PRIVILEGES;"
RUN composer create-project sylius/sylius-standard .

RUN service mysql start \
    && bin/console sylius:install -n

RUN yarn install \
    && yarn build

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]