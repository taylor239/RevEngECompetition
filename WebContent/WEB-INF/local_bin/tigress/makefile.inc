
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

ifeq ($(strip $(UNAME_S)),Linux)
   ENV=${UNAME_M}:${UNAME_S}:Gcc:4.6
else
   ENV=${UNAME_M}:${UNAME_S}:Clang:5.1
endif

