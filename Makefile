
DESTDIR ?=
PREFIX = /usr/local

CC ?= gcc
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Linux)
CFLAGS += -std=gnu99 -Wall -Wextra -Wshadow -Werror -fvisibility=hidden
LDFLAGS += -Wl,--no-undefined
endif

ifeq ($(UNAME_S),Darwin)
CFLAGS += -I$(shell brew --prefix)/include -std=gnu99 -Wall -Wextra -Wshadow -Werror -fvisibility=hidden
LDFLAGS += -L$(shell brew --prefix)/lib -largp # -Wl,--no-undefined
endif

ifeq ($(DEBUG),1)
CFLAGS += -O0 -g -DDEBUG
else
CFLAGS += -O2 -DNDEBUG
endif

all: ttymidi ttymidi.so

debug:
	$(MAKE) DEBUG=1

ttymidi: src/ttymidi.c src/mod-semaphore.h
	$(CC) $< $(CFLAGS) $(shell pkg-config --cflags --libs jack) $(LDFLAGS) -lpthread -o $@

ttymidi.so: src/ttymidi.c src/mod-semaphore.h
	$(CC) $< $(CFLAGS) $(shell pkg-config --cflags --libs jack) $(LDFLAGS) -fPIC -lpthread -shared -o $@

install: ttymidi ttymidi.so
	install -m 755 ttymidi    $(DESTDIR)$(PREFIX)/bin/
	install -m 755 ttymidi.so $(DESTDIR)$(shell pkg-config --variable=libdir jack)/jack/

clean:
	rm -f ttymidi ttymidi.so

uninstall:
	rm $(DESTDIR)$(PREFIX)/bin/ttymidi
	rm $(DESTDIR)$(shell pkg-config --variable=libdir jack)/jack/ttymidi.so
