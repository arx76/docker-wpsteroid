FROM ubuntu:14.04
MAINTAINER Alex Newman <alex@newman.pro>

# TODO: Merge all apt-get update in one to minimize building time!

# Let the container know that there is no TTY
ENV DEBIAN_FRONTEND noninteractive

# Install necessary packages for proper system state
RUN apt-get -y update && apt-get install -y \
    software-properties-common \
    sysv-rc-conf \
    python-apt \ 
    python-pycurl \
    python-mysqldb \
    git \
    curl \
    unzip \
    php5-mysql \
    traceroute \ 
    ack-grep \
    subversion \
    autojump \
    siege
  
# Get Composer
RUN curl -o /usr/local/bin/composer https://getcomposer.org/composer.phar \
 && chmod 0755 /usr/local/bin/composer
  
# Get PsySH
RUN curl -o /usr/local/bin/psysh http://psysh.org/psysh \
 && chmod 0755 /usr/local/bin/psysh
 
# Get Boris
RUN curl -o /usr/local/bin/boris https://github.com/d11wtq/boris/releases/download/v1.0.8/boris.phar \
 && chmod 0755 /usr/local/bin/boris
 
# HVVM (default) -------------------------

# Enable HHVM repo key
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449

# Enable HHVM repo
RUN add-apt-repository -y "deb http://dl.hhvm.com/ubuntu $(lsb_release -sc) main"

# Install HHVM
RUN apt-get -y update && apt-get install -y hhvm

# TODO: Template /etc/hhvm/server.ini & restart service?
# TODO: Template /etc/hhvm/php.ini & restart service?

# Ensure HHVM is running 
RUN service hhvm restart

# PHP-FPM (fallback) ---------------------

# Install PHP packages
RUN apt-get install -y \
    php5 \
    php5-cli \
    php5-imagick \
    php5-curl \
    php5-gd \
    php5-fpm \
    php5-memcache \
    php5-memcached \
    php5-xdebug \
    phpunit
    
# TODO: Template fpm/php.ini & restart fpm service?

# Memcached ------------------------------

# Install memcached server
RUN apt-get install -y \
    memcached
    
# TODO: Memcached template
RUN service memcached restart

# Percona Server & Client ----------------

# TODO: MySQL template?

# Enable Percona repo
RUN wget https://repo.percona.com/apt/percona-release_0.1-3.$(lsb_release -sc)_all.deb \
 && dpkg -i percona-release_0.1-3.$(lsb_release -sc)_all.deb \
 && rm -f percona-release_0.1-3.$(lsb_release -sc)_all.deb
 
# Install Percona
RUN apt-get -y update && apt-get install -y \
    percona-server-server-5.6 \
    percona-server-client-5.6
    
# TODO update-rc.d mysql defaults & restart?

# NGiNX ----------------------------------

# Enable NGiNX repo key
RUN apt-key adv --fetch-keys http://nginx.org/keys/nginx_signing.key

# Enable NGiNX repo
RUN add-apt-repository -y "deb http://nginx.org/packages/ubuntu $(lsb_release -sc) nginx"

# Install NGiNX
RUN apt-get -y update && apt-get install -y nginx

# TODO: update-rc.d nginx defaults & restart?

# TODO: Ensure /etc/nginx directories exist
# TODO: Template /etc/nginx/nginx.conf
# TODO: Template /etc/nginx/conf.d/upstream.conf
# TODO: Remove /etc/nginx/sites-enabled/default
# TODO: Remove /etc/nginx/conf.d/default.conf
# TODO: Remove /etc/nginx/conf.d/example_ssl.conf
# TODO: Make directory /var/www/html (wp_doc_root -> variable)
# TODO: Setup wp_doc_root with web_user (www-data), web_group (www-data)

# WP-CLI ---------------------------------

# Prepare location for WP-CLI
RUN install -d -m 0755 -o root -g root /usr/share/wp-cli

# Install WP-CLI
RUN curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/share/wp-cli/wp

# Set executive bits on WP-CLI
RUN chmod 755 /usr/share/wp-cli/wp

# Symlink WP-CLI
RUN ln -s /usr/share/wp-cli/wp /usr/local/bin/wp
    
# Security -------------------------------

# TODO: Secure MySQL and so on
    
# Cleanup --------------------------------

RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

EXPOSE 3306
EXPOSE 443
EXPOSE 80
