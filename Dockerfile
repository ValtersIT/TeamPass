# This file contains commands what happens when the Docker Container Starts
# I have added comments to each function so that it is understandable for people who are learning to create Docker images.
# This Docker container with all startups is written after being sick for 5 Months and not being active in >
# < IT at all in part of recovering from illness, so it is more like training to get my brain back on track for new even >
# < more difficult challenges

# YouTube: https://www.youtube.com/@valters_eu
# Twitter: https://twitter.com/valters_eu
# Website: https://www.valters.eu

# We will be using Ubuntu's latest docker image
FROM ubuntu:latest
# Just some information
ENV MAINTAINER https://www.valters.eu
ENV maintainer="docker@valters.eu"

# Let's install UTF8 Support in the Docker container
RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# Let's select the PHP Version that we will be installing so that the PHP installation 
# when building the Docker image happens automatically all modules of PHP That will be installed will be listed below
ARG PHP_VERSION=8.3
ENV PHPV=$PHP_VERSION

# Let's specify Group and User that we will use for Apache2 to run
ARG AUSER=janisv
ARG AGROUP=janisvg

# Let's specify the Docker container Apache2 admin Email
ARG AMAIL=somemail@valters.eu

# Specify Docker container Timezone
ENV TZ=Europe/Riga
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Let's update our Distro repository and install web server apache2 its utils, Git, and cron after cleaning the cache
RUN  apt-get update  && apt-get install -y \
     apache2 \
     apache2-utils \
     git \
     cron \
     && \
     rm -rf /var/cache/apt/*

# Let's enable apache2 to rewrite so that links can be rewritten using .htaccess etc. 
# Also enable SSL and get real user IP from the header this is recommended if you are using NGINX reverse proxy
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod remoteip

# Let's install several required software for certification and to activate the PHP repository.
RUN apt install -y software-properties-common ca-certificates lsb-release apt-transport-https 

# Let's activate Ondrej PHP repository from where to download PHP and the modules, that we have specified below
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php 
RUN apt update 
RUN apt install -y \
      php$PHP_VERSION \ 
      php$PHP_VERSION-cli \
      php$PHP_VERSION-phar \
      php$PHP_VERSION-zip \ 
      php$PHP_VERSION-bz2 \
      php$PHP_VERSION-ctype \
      php$PHP_VERSION-curl \
      php$PHP_VERSION-mysqli \
      php$PHP_VERSION-mysql \
      php$PHP_VERSION-ldap \      
      php-json \
      php$PHP_VERSION-xml \
      php$PHP_VERSION-dom \
      php$PHP_VERSION-iconv \
      php$PHP_VERSION-exif \
      php$PHP_VERSION-xdebug \
      php$PHP_VERSION-intl \
      php$PHP_VERSION-gd \
      php$PHP_VERSION-mbstring \
      php$PHP_VERSION-apcu \
      php$PHP_VERSION-opcache \
      php$PHP_VERSION-simplexml \
      php$PHP_VERSION-tokenizer \
      php$PHP_VERSION-soap \
      php$PHP_VERSION-gmp \
      php$PHP_VERSION-bcmath \
      php$PHP_VERSION-xmlrpc \
      php$PHP_VERSION-xmlreader \
      php$PHP_VERSION-tidy \
      php$PHP_VERSION-fileinfo \
      php$PHP_VERSION-imap \
      && \
      rm -rf /var/cache/apt/*

RUN update-alternatives --set php /usr/bin/php$PHP_VERSION

# Let's create a user and a group once the user and group is created let's add the user to the group
RUN groupadd -g 2000 $AGROUP 
RUN useradd -s /sbin/nologin $AUSER
RUN usermod -a -G $AGROUP $AUSER

# Let's install nano editor, curl, time support zip
RUN apt-get update && apt-get install -y \
     nano \
     curl \
     tzdata \
     zip \
     && \
     rm -rf /var/cache/apt/*

# Now, let's create directories and do several webserver configurations including changing the user and group that runs the web server
RUN mkdir -p /run/apache2 && chown -R www-data:www-data /run/apache2 && chown -R $AUSER:$AGROUP /var/www/html/ && \
    ln -s /var/log/apache2 /var/www/logs && \
    sed -i 's#Options Indexes FollowSymLinks#\nOptions +FollowSymLinks -Indexes#' /etc/apache2/apache2.conf && \
    sed -i 's#ServerTokens OS#\nServerTokens Prod#' /etc/apache2/conf-enabled/security.conf && \
    sed -i "s#export APACHE_RUN_USER=www-data#\nexport APACHE_RUN_USER=$AUSER#" /etc/apache2/envvars && \
    sed -i "s#export APACHE_RUN_GROUP=www-data#\nexport APACHE_RUN_GROUP=$AGROUP#" /etc/apache2/envvars && \
    sed -i 's#ServerSignature On#\nServerSignature Off#' /etc/apache2/conf-enabled/security.conf && \
    sed -i "s#ServerAdmin webmaster@localhost#\nServerAdmin $AMAIL#" /etc/apache2/sites-enabled/000-default.conf && \
    sed -i '13 i RemoteIPHeader CF-Connecting-IP' /etc/apache2/sites-enabled/000-default.conf && \
    sed -i '22 i  CustomLog ${APACHE_LOG_DIR}/access.log combined' /etc/apache2/sites-enabled/000-default.conf && \
    sed -i '23 i  <Directory /var/www/html> \n Options +FollowSymLinks -Indexes \n AllowOverride All \n Require all granted \n </Directory>' /etc/apache2/sites-enabled/000-default.conf 

# Let's make several changes to our PHP so that we have the required parameters for TeamPass to work properly
RUN sed -i 's#display_errors = Off#display_errors = Off#' /etc/php/$PHP_VERSION/cli/php.ini && \
    sed -i 's#upload_max_filesize = 2M#upload_max_filesize = 250M#' /etc/php/$PHP_VERSION/cli/php.ini && \
    sed -i 's#post_max_size = 8M#post_max_size = 250M#' /etc/php/$PHP_VERSION/cli/php.ini && \
    sed -i 's#session.cookie_httponly =#session.cookie_httponly = true#' /etc/php/$PHP_VERSION/cli/php.ini && \
    sed -i 's#max_input_time = 60#max_input_time = 250#' /etc/php/$PHP_VERSION/cli/php.ini && \
    sed -i 's#memory_limit = -1#memory_limit = 512M#' /etc/php/$PHP_VERSION/cli/php.ini && \
    sed -i 's#;max_input_vars = 1000#max_input_vars = 9000#' /etc/php/$PHP_VERSION/cli/php.ini && \
    sed -i 's#error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT#error_reporting = E_ALL#' /etc/php/$PHP_VERSION/cli/php.ini && \
    sed -i 's#display_errors = Off#display_errors = Off#' /etc/php/$PHP_VERSION/apache2/php.ini && \
    sed -i 's#upload_max_filesize = 2M#upload_max_filesize = 250M#' /etc/php/$PHP_VERSION/apache2/php.ini && \
    sed -i 's#post_max_size = 8M#post_max_size = 250M#' /etc/php/$PHP_VERSION/apache2/php.ini && \
    sed -i 's#session.cookie_httponly =#session.cookie_httponly = true#' /etc/php/$PHP_VERSION/apache2/php.ini && \
    sed -i 's#max_input_time = 60#max_input_time = 250#' /etc/php/$PHP_VERSION/apache2/php.ini && \
    sed -i 's#memory_limit = -1#memory_limit = 512M#' /etc/php/$PHP_VERSION/apache2/php.ini && \
    sed -i 's#;max_input_vars = 1000#max_input_vars = 9000#' /etc/php/$PHP_VERSION/apache2/php.ini && \
    sed -i "s#;date.timezone =#date.timezone = "$TZ"#" /etc/php/$PHP_VERSION/apache2/php.ini && \
    sed -i 's#error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT#error_reporting = E_ALL#' /etc/php/$PHP_VERSION/apache2/php.ini

# Let's enable the IP module to get real user IP
RUN echo "LoadModule remoteip_module modules/mod_remoteip.so" >> /etc/apache2/apache2.conf

# Let's copy the file into the Docker image so that once we run our Docker container we have the file inside
COPY entrypoint.sh /entrypoint.sh

# Let's give the file proper execution permissions
RUN chmod +x /entrypoint.sh

# Specify what directory opens once we enter our Docker container
WORKDIR /var/www/

# Let's expose default web server ports 80 for HTTP traffic and 443 for HTTPS traffic
EXPOSE 80 443
#CMD ( cron && tail -f /var/log/cron.log & ) && apachectl -D FOREGROUND 

# Specify that once our Docker container starts, to execute the following file with commands. 
# Above we mentioned copying the file with the COPY command into a Docker image/container
ENTRYPOINT ["/entrypoint.sh"]