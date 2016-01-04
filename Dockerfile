FROM ubuntu:14.04
MAINTAINER Alex Newman <alex@newman.pro>

# TODO: Variables!
# DONE: Merge all apt-get update in one to minimize building time!

# Let the container know that there is no TTY
ENV DEBIAN_FRONTEND noninteractive

# Enable all repositories ================

# Need to add-apt-repository
RUN apt-get install -y \
    software-properties-common \
    curl

# Enable HHVM repo
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449 \
 && add-apt-repository -y "deb http://dl.hhvm.com/ubuntu $(lsb_release -sc) main"
 
# Enable Percona repo
RUN curl https://repo.percona.com/apt/percona-release_0.1-3.$(lsb_release -sc)_all.deb -o /tmp/percona-release_0.1-3.$(lsb_release -sc)_all.deb \
 && dpkg -i /tmp/percona-release_0.1-3.$(lsb_release -sc)_all.deb \
 && rm -f /tmp/percona-release_0.1-3.$(lsb_release -sc)_all.deb
 
# Enable NGiNX repo
RUN apt-key adv --fetch-keys http://nginx.org/keys/nginx_signing.key \
 && add-apt-repository -y "deb http://nginx.org/packages/ubuntu $(lsb_release -sc) nginx"

# TODO: Update to Varnish 4.1 (configuration changed)
# Enable Varnish repo (curl to grab + apt-transport-https)
RUN curl https://repo.varnish-cache.org/GPG-key.txt | apt-key add - \
 && add-apt-repository -y "deb https://repo.varnish-cache.org/ubuntu/ $(lsb_release -sc) varnish-3.0"

# Install basic packages =================

# Install necessary packages for proper system state
RUN apt-get -y update && apt-get install -y \
    apt-transport-https \
    sysv-rc-conf \
    python-apt \ 
    python-pycurl \
    python-mysqldb \
    git \
    unzip \
    php5-mysql \
    traceroute \ 
    ack-grep \
    subversion \
    autojump \
    siege
  
# Get Composer
RUN curl https://getcomposer.org/composer.phar -o /usr/local/bin/composer \
 && chmod 0755 /usr/local/bin/composer
  
# Get PsySH
RUN curl http://psysh.org/psysh -o /usr/local/bin/psysh \
 && chmod 0755 /usr/local/bin/psysh
 
# Get Boris
RUN curl https://github.com/d11wtq/boris/releases/download/v1.0.8/boris.phar -o /usr/local/bin/boris \
 && chmod 0755 /usr/local/bin/boris
 
# HVVM (default) -------------------------

# Install HHVM
RUN apt-get install -y hhvm

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

# Install Percona
RUN apt-get install -y \
    percona-server-server-5.6 \
    percona-server-client-5.6
    
# TODO update-rc.d mysql defaults & restart?

# NGiNX ----------------------------------

# Install NGiNX
RUN apt-get install -y nginx

# TODO: Why?
RUN update-rc.d nginx defaults

# Ensure /etc/nginx directories exist
RUN install -d -m 0755 -o root -g root /etc/nginx/sites-available
RUN install -d -m 0755 -o root -g root /etc/nginx/sites-enabled

# Template /etc/nginx/nginx.conf
COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf

# Template /etc/nginx/conf.d/upstream.conf
COPY etc/nginx/conf.d/upstream.conf /etc/nginx/conf.d/upstream.conf

# Remove defaults
RUN rm -f /etc/nginx/sites-enabled/default \
 && rm -f /etc/nginx/conf.d/default.conf \
 && rm -f /etc/nginx/conf.d/example_ssl.conf

# Make directory /var/www/html (wp_doc_root -> variable) with web_user (www-data), web_group (www-data)
RUN install -d -m 0755 -o www-data -g www-data /var/www/html

# Restart after configuration
RUN service nginx restart

# WP-CLI ---------------------------------

# Prepare location for WP-CLI
RUN install -d -m 0755 -o root -g root /usr/share/wp-cli

# Install WP-CLI
RUN curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/share/wp-cli/wp

# Set executive bits on WP-CLI
RUN chmod 755 /usr/share/wp-cli/wp

# Symlink WP-CLI
RUN ln -s /usr/share/wp-cli/wp /usr/local/bin/wp

# Varnish --------------------------------

# Install Varnish
RUN apt-get install -y varnish
# TODO: Varnish reload?

# Template /etc/varnish/default.vcl (root:root 0644)
COPY etc/varnish/default.vcl /etc/varnish/default.vcl

# Template /etc/default/* (root:root 0644)
COPY etc/default/varnish /etc/default/varnish
COPY etc/default/varnishncsa /etc/default/varnishncsa

# Ensure Varnish is running & reload configuration
RUN service varnish restart && service varnishncsa restart
    
# Security -------------------------------

# TODO: Secure MySQL and so on
    
# Cleanup --------------------------------

RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

EXPOSE 3306
EXPOSE 443
EXPOSE 80
