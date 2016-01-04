FROM ubuntu:14.04
MAINTAINER Alex Newman <alex@newman.pro>

#Let the container know that there is no TTY
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
    siege \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
  
# Get Composer
RUN curl -o /usr/local/bin/composer https://getcomposer.org/composer.phar \
 && chmod 0755 /usr/local/bin/composer
  
# Get PsySH
RUN curl -o /usr/local/bin/psysh http://psysh.org/psysh \
 && chmod 0755 /usr/local/bin/psysh
 
# Get Boris
RUN curl -o /usr/local/bin/boris https://github.com/d11wtq/boris/releases/download/v1.0.8/boris.phar \
 && chmod 0755 /usr/local/bin/boris
 
# HVVM -----------------------------------

# Enable HHVM repo key
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449

# Enable HHVM repo
RUN add-apt-repository -y "deb http://dl.hhvm.com/ubuntu $(lsb_release -sc) main"

# Install HHVM
RUN apt-get -y update && apt-get install -y hhvm

# TODO: Template /etc/hhvm/server.ini
# TODO: Template /etc/hhvm/php.ini

# Ensure HHVM is running 
RUN service hhvm start

EXPOSE 3306
EXPOSE 443
EXPOSE 80
