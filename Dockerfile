# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie

# set version label
ARG BUILD_DATE
ARG VERSION
ARG GZDOOM_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE="Blade of Agony" \
    DOOMWADDIR="/opt/boa" \
    PIXELFLUX_WAYLAND=true

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/boa-logo.png && \
  echo "**** install gzdoom ****" && \
  curl -o \
    /tmp/gzdoom.deb -L \
    "https://github.com/ZDoom/gzdoom/releases/download/g4.11.3/gzdoom_4.11.3_amd64.deb" && \
  cd /tmp && \
  apt-get update && \
  apt install -y \
    ./gzdoom.deb \
    p7zip-full && \
  echo "**** build blade of agony ****" && \
  mkdir /opt/boa && \
  if [ -z ${BOA_RELEASE+x} ]; then \
    BOA_RELEASE=$(curl -sX GET "https://api.github.com/repos/Realm667/WolfenDoom/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/boa.tar.gz -L \
    "https://github.com/Realm667/WolfenDoom/archive/refs/tags/${BOA_RELEASE}.tar.gz" && \
  cd /tmp && \
  tar xf boa.tar.gz && \
  cd WolfenDoom* && \
  ./build.sh --release --no-update && \
  mv \
    ../wolf_boa* \
    /opt/boa/wolf_boa.ipk3 && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3001

VOLUME /config
