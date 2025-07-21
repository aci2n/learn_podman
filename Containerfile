FROM archlinux:latest as base
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

FROM build_base AS build_client
RUN pacman -S --noconfirm curl
COPY Makefile client.c ./
RUN make client

##

FROM base AS client
RUN pacman -S --noconfirm curl
COPY --from=build_client /build/client /usr/local/bin/
CMD ["client"]
