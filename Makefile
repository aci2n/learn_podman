
server: LDLIBS := -lmicrohttpd
server: server.o

client: LDLIBS := -lcurl
client: client.o
