## -*- mode: makefile; tab-width: 4 -*-
## $Id: Makefile.am 18620 2009-07-17 16:45:08Z romw $

AUTOMAKE_OPTIONS = foreign

include Makefile.incl

## make sure rebuilding uses the right aclocal-switches
ACLOCAL_AMFLAGS = -I m4

if ENABLE_LIBRARIES
   API_SUBDIRS = api lib
endif

if ENABLE_SERVER
   SERVER_SUBDIRS = db test py sched apps tools samples/example_app
endif

if ENABLE_CLIENT
   CLIENT_SUBDIRS = client client/scripts
endif

if ENABLE_MANAGER
   CLIENTGUI_SUBDIRS = clientgui clientgui/res locale
endif

# ORDER MATTERS below.  One must build dependencies FIRST, then things
# that depend on them later
SUBDIRS = m4 $(API_SUBDIRS) $(SERVER_SUBDIRS) $(CLIENT_SUBDIRS) $(CLIENTGUI_SUBDIRS) doc

# Putting a directory name recursively copies the entire contents - the
# dist-hook below gets rid of CVS directories.

EXTRA_DIST =                                    \
	win_build                                   \
	doc                                         \
	stripchart                                  \
    INSTALL										

if INSTALL_HEADERS
pkginclude_HEADERS = \
    version.h
endif

# Add a stage target for staging a distribution

clean-generic:
	rm -rf stage

stage: all
	if [ ! -d stage ] ; then mkdir stage ; fi
	rm -rf stage/*
	$(MAKE) DESTDIR=$(PWD)/stage install

dist-hook:
	rm -rf `find $(distdir) -name .backup -prune -o -name '*~' -o -name CVS`
#	cd $(distdir) && ./_autosetup
