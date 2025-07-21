FROM docker.io/archlinux/archlinux:latest as base
RUN pacman -Syu --noconfirm

##

FROM base AS build_base
RUN pacman -S --noconfirm	make gcc
WORKDIR /build

##

FROM build_base AS build_server
RUN pacman -S --noconfirm libmicrohttpd
COPY Makefile server.c ./
RUN make server

##

FROM base AS server
RUN pacman -S --noconfirm libmicrohttpd
COPY --from=build_server /build/server /usr/local/bin/
CMD ["server"]

##

FROM docker.io/caddy/caddy:alpine AS caddy
COPY Caddyfile /etc/caddy/Caddyfile
