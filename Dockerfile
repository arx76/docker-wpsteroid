FROM ubuntu:14.04
MAINTAINER Alex Newman <alex@newman.pro>

#Let the container know that there is no TTY
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && apt-get install -y \
    software-properties-common \
    #TODO
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
  
EXPOSE 3306
EXPOSE 443
EXPOSE 80
