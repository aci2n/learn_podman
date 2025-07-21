##

server: LDLIBS := -lmicrohttpd
server: server.o

client: LDLIBS := -lcurl
client: client.o

##

REMOTE := root@135.181.201.184
REPOSITORY := docker.io/aci2n/private
VERSION = $(shell git rev-parse --short HEAD)

# $(1): target (from Dockerfile)
define build_image
	podman build --platform linux/amd64 --target '$(1)' --tag '$(REPOSITORY):$(1)-$(VERSION)' .
	podman tag '$(REPOSITORY):$(1)-$(VERSION)' '$(REPOSITORY):$(1)-latest'
endef

# $(1): target (from Dockerfile)
# $(2): tag suffix
define push_image
	podman tag '$(REPOSITORY):$(1)-latest' '$(REPOSITORY):$(1)-$(2)'
	podman push '$(REPOSITORY):$(1)-$(2)'
endef

build_server:
	$(call build_image,server)
push_server_prod:
	$(call push_image,server,prod)
push_server_beta:
	$(call push_image,server,beta)

build_client:
	$(call build_image,client)
push_client_prod:
	$(call push_image,client,prod)

build_caddy:
	$(call build_image,caddy)
push_caddy:
	$(call push_image,caddy,latest)

##

define sync_quadlets
	rsync --recursive --delete quadlets/ '$(1)'
endef

local_quadlets:
	$(call sync_quadlets,/run/containers/systemd/piano-tree)

remote_quadlets:
	$(call sync_quadlets,$(REMOTE):/etc/containers/systemd/piano-tree)

