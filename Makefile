
GCC	:= gcc
LDFLAGS	:= -framework Foundation
CFLAGS	:= -I.

all: twitter-xauth

twitter-xauth: twitter-xauth.m TwitterXAuth.m NSData+Base64.m
	$(GCC) $(LDFLAGS) $(CFLAGS) $^ -o $@
