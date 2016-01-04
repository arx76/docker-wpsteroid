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
    
# TODO update-rc.d mysql defaults & restart / reload?
    
# Security -------------------------------

# TODO: Secure MySQL and so on
    
# Cleanup --------------------------------

RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

EXPOSE 3306
EXPOSE 443
EXPOSE 80
