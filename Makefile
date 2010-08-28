# Created by Eric Johnson on 08/27/2010.
# Copyright 2010 Eric Johnson. All rights reserved.
#
# Permission is given to use this source code file, free of charge, in any
# project, commercial or otherwise, entirely at your risk, with the condition
# that any redistribution (in part or whole) of source code must retain
# this copyright and permission notice. Attribution in compiled projects is
# appreciated but not required.

GCC	:= gcc
LDFLAGS	:= -framework Foundation
CFLAGS	:= -I.

all: twitter-xauth

twitter-xauth: twitter-xauth.m TwitterXAuth.m NSData+Base64.m
	$(GCC) $(LDFLAGS) $(CFLAGS) $^ -o $@
