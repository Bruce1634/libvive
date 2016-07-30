
PREFIX=/usr/local

CFLAGS += -g
CFLAGS += -O0
CFLAGS += -I deps

vivehid: vivehid.c
	$(CC) $(CFLAGS) $< -o $@ -lhidapi-hidraw

OS ?= $(shell uname)

VIVEGUI_SRC += $(wildcard deps/*/*.c)
VIVEGUI_SRC += $(wildcard vivegui/*.c)

LIBVIVE_SRC += libvive/libvive.c

VIVEGUI_CFLAGS += -L libvive -I libvive -l vive_static
VIVEGUI_CFLAGS += -l glfw
VIVEGUI_CFLAGS += -l pthread
VIVEGUI_CFLAGS += -l hidapi-hidraw
VIVEGUI_CFLAGS += -l GLEW
VIVEGUI_CFLAGS += -l GLU

ifeq (Darwin, $(OS))
VIVEGUI_CFLAGS += -framework Foundation
VIVEGUI_CFLAGS += -framework OpenGL
endif

all: vivehid vivegui/vivegui libvive/libvive.so libvive/libvive_static.a

vivegui/vivegui: $(VIVEGUI_SRC) libvive/libvive_static.a
	$(CC) $(CFLAGS) $(VIVEGUI_CFLAGS) $^ -o $@

LIBVIVE_LIBS = libvive/libvive.so libvive/libvive_static.a
LIBVIVE_OBJS = libvive/libvive.o

libvive/libvive.so: $(LIBVIVE_OBJS)
	$(CC) $(CFLAGS) $(LIBVIVE_CFLAGS) $< -shared -o $@

libvive/libvive_static.a: $(LIBVIVE_OBJS)
	ar rcs $@ $<

libvive/libvive.o: $(LIBVIVE_SRC)
	$(CC) $(CFLAGS) $(LIBVIVE_CFLAGS) -c -fPIC $^ -o $@

clean:
	rm -f vivegui/vivegui vivehid
	rm -f $(LIBVIVE_LIBS) $(LIBVIVE_OBJS)
