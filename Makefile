#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the Common Development
# and Distribution License Version 1.0 (the "License").
#
# You can obtain a copy of the license at
# http://www.opensource.org/licenses/CDDL-1.0.  See the License for the
# specific language governing permissions and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each file and
# include the License file in a prominent location with the name LICENSE.CDDL.
# If applicable, add the following below this CDDL HEADER, with the fields
# enclosed by brackets "[]" replaced with your own identifying information:
#
# Portions Copyright (c) [yyyy] [name of copyright owner]. All rights reserved.
#
# CDDL HEADER END
#

#
# Copyright (c) 2013--2017, Regents of the University of Minnesota.
# All rights reserved.
#
# Contributors:
#    Ryan S. Elliott
#

#
# Release: This file is part of the kim-api.git repository.
#

ifeq ($(wildcard Makefile.KIM_Config),)
  $(error Makefile.KIM_Config does not exist.  Please create this file in order to compile the KIM API package)
endif
include Makefile.KIM_Config

#
# List of available targets
#
.PHONY: help

help:
	@printf "TARGETS FOR HELP\n"
	@printf "'help'                       -- print this list of targets\n"
	@printf "\n"
	@printf "TARGETS FOR BUILDING AND CLEANING THE KIM API PACKAGE\n"
	@printf "'all'                        -- build the KIM API library and all 'added'\n"
	@printf "                                Model Drivers and Models; same as 'make'\n"
	@printf "'clean'                      -- delete appropriate .o, .mod, .a, .so and\n"
	@printf "                                executable files from src/ directory and\n"
	@printf "                                its subdirectories\n"
	@printf "\n"
	@printf "TARGETS FOR INSTALLING THE KIM API PACKAGE\n"
	@printf "'install'                    -- install KIM API library, associated\n"
	@printf "                                executable utilities, and 'added' Model\n"
	@printf "                                Drivers and Models to system-wide location\n"
	@printf "                                as described in item 7 below.\n"
	@printf "'install-set-default-to-vX'  -- create generic\n"
	@printf "                                $(includedir)/$(package_name) and\n"
	@printf "                                ${libdir}/${package_name} symlinks to the\n"
	@printf "                                corresponding $(package_name)-vX versions.\n"
	@printf "                                This effectively sets the 'default'\n"
	@printf "                                library available for users on the system.\n"
	@printf "\n"
	@printf "TARGETS FOR UNINSTALLING THE KIM API PACKAGE\n"
	@printf "'uninstall'                  -- delete files installed by 'make install'\n"
	@printf "'uninstall-set-default'      -- remove the generic\n"
	@printf "                                $(includedir)/$(package_name) and\n"
	@printf "                                $(libdir)/$(package_name) symlinks.\n"
	@printf "\n"


#
# Main build settings and rules
#
.PHONY: all config utils-all kim-api-objects kim-api-libs

all: config kim-api-objects kim-api-libs utils-all

# Add local Makefile to KIM_MAKE_FILES
KIM_MAKE_FILES += Makefile


#%% added srcdir and examplesdir
srcdir = $(KIM_DIR)/src
examplesdir = examples

# build targets involved in "make all"

KIM_API_CONFIG_FILES = $(srcdir)/Makefile.KIM_Config \
                       $(srcdir)/utils/Makefile.KIM_Config
KIM_API_EXAMPLES_CONFIG_FILES = $(KIM_DIR)/$(examplesdir)/Makefile.KIM_Config \
                                $(KIM_DIR)/$(examplesdir)/$(modelsdir)/Makefile.KIM_Config \
                                $(KIM_DIR)/$(examplesdir)/$(modeldriversdir)/Makefile.KIM_Config
KIM_CONFIG_FILES = $(KIM_API_CONFIG_FILES) $(KIM_API_EXAMPLES_CONFIG_FILES)

KIM_SIMULATOR_CONFIG_FILES = $(KIM_DIR)/$(examplesdir)/openkim_tests/Makefile.KIM_Config_Helper \
                             $(KIM_DIR)/$(examplesdir)/simulators/Makefile.KIM_Config_Helper

config: $(KIM_CONFIG_FILES) $(KIM_SIMULATOR_CONFIG_FILES)

$(KIM_API_CONFIG_FILES): $(KIM_MAKE_FILES)
	$(QUELL)if test -d $(dir $@); then \
                  printf 'Creating... KIM_Config file..... $(patsubst $(KIM_DIR)/%,%,$@).\n'; \
                  printf '# This file is automatically generated by the KIM API build system.\n' >  $@; \
                  printf '# Do not edit!\n'                                                      >> $@; \
                  printf '\n'                                                                    >> $@; \
                  printf 'include $(KIM_DIR)/Makefile.KIM_Config\n'                              >> $@; \
                fi

$(KIM_API_EXAMPLES_CONFIG_FILES): $(KIM_MAKE_FILES)
	$(QUELL)if test -d $(dir $@); then \
                  printf 'Creating... KIM_Config file..... $(patsubst $(KIM_DIR)/%,%,$@).\n'; \
                  printf '# This file is automatically generated by the KIM API build system.\n' >  $@; \
                  printf '# Do not edit!\n'                                                      >> $@; \
                  printf '\n'                                                                    >> $@; \
                  printf 'include $(package_dir)/Makefile.KIM_Config\n'                          >> $@; \
                fi

$(KIM_SIMULATOR_CONFIG_FILES): $(KIM_MAKE_FILES)
	$(QUELL)if test -d $(dir $@); then \
                  printf 'Creating... KIM_Config_Helper file..... $(patsubst $(KIM_DIR)/%,%,$@).\n'; \
                  printf '# This file is automatically generated by the KIM API build system.\n'        >  $@; \
                  printf '# Do not edit!\n'                                                             >> $@; \
                  printf '\n'                                                                           >> $@; \
                  printf 'KIM_CONFIG_HELPER = $(package_dir)/bin/$(full_package_name)-build-config\n'   >> $@; \
                fi

kim-api-objects: $(KIM_MAKE_FILES) kim-api-objects-making-echo
	$(QUELL)$(MAKE) $(MAKE_FLAGS) -C $(srcdir) objects

kim-api-libs: $(KIM_MAKE_FILES) kim-api-libs-making-echo
	$(QUELL)$(MAKE) $(MAKE_FLAGS) -C $(srcdir) libs

utils-all: $(KIM_MAKE_FILES) src/utils-making-echo
	$(QUELL)$(MAKE) $(MAKE_FLAGS) -C $(srcdir)/utils all


#
# Main clean rules and targets
#
.PHONY: clean kim-api-clean config-clean utils-clean

clean: config kim-api-clean utils-clean config-clean

# build targets involved in "make clean"
kim-api-clean:
	$(QUELL)$(MAKE) $(MAKE_FLAGS) -C $(srcdir) clean
	$(QUELL)rm -f kim.log

utils-clean:
	$(QUELL)$(MAKE) $(MAKE_FLAGS) -C $(srcdir)/utils clean

config-clean:
	@printf "Cleaning... KIM_Config files.\n"
	$(QUELL)rm -f $(KIM_CONFIG_FILES)
	$(QUELL)rm -f $(KIM_SIMULATOR_CONFIG_FILES)


#
# Main install settings and rules
#
.PHONY: install install-check installdirs kim-api-objects-install kim-api-libs-install config-install utils-install

install: install-check config kim-api-objects-install kim-api-libs-install utils-install config-install

# build targets involved in "make install"
install_builddir = $(dest_package_dir)/$(builddir)
install_make = Makefile.Generic Makefile.LoadDefaults Makefile.Model Makefile.ModelDriver Makefile.ParameterizedModel Makefile.SimulatorModel Makefile.SanityCheck parameterized_model.cpp
install_compilerdir = $(dest_package_dir)/$(buildcompilerdir)
install_compiler = Makefile.GCC Makefile.INTEL
install_linkerdir = $(dest_package_dir)/$(buildlinkerdir)
install_linker = Makefile.DARWIN Makefile.FREEBSD Makefile.LINUX

install-check:
	$(QUELL)if test -d "$(dest_package_dir)"; then \
                  rm -rf "$(install_linkerdir)"; \
                  rm -rf "$(install_compilerdir)"; \
                  rm -rf "$(install_builddir)"; \
                  rm -f  "$(dest_package_dir)/Makefile.KIM_Config"; \
                  rm -f  "$(dest_package_dir)/Makefile.Version"; \
                fi

kim-api-objects-install:
	$(QUELL)$(MAKE) $(MAKE_FLAGS) -C $(srcdir) objects-install

kim-api-libs-install:
	$(QUELL)$(MAKE) $(MAKE_FLAGS) -C $(srcdir) libs-install

utils-install:
	$(QUELL)$(MAKE) $(MAKE_FLAGS) -C $(srcdir)/utils install

config-install: installdirs
	@printf "Installing...($(dest_package_dir))................................. KIM_Config files"
        # Install make directory
	$(QUELL)for fl in $(install_make); do $(INSTALL_PROGRAM) -m 0644 "$(builddir)/$$fl" "$(install_builddir)/$$fl"; done
        # Install compiler defaults directory
	$(QUELL)for fl in $(install_compiler); do $(INSTALL_PROGRAM) -m 0644 "$(buildcompilerdir)/$$fl" "$(install_compilerdir)/$$fl"; done
        # Install linker defaults directory
	$(QUELL)for fl in $(install_linker); do $(INSTALL_PROGRAM) -m 0644 "$(buildlinkerdir)/$$fl" "$(install_linkerdir)/$$fl"; done
        # Install KIM_Config file
	$(QUELL)fl="Makefile.KIM_Config" && \
                sed -e 's|^[[:space:]]*KIM_DIR[[:space:]]*:*=.*$$|KIM_DIR = $(package_dir)|' \
                    -e 's|^[[:space:]]*prefix[[:space:]]*:*=.*$$|prefix = $(prefix)|' \
                $$fl > "$(dest_package_dir)/$$fl" && \
                chmod 0644 "$(dest_package_dir)/$$fl"
        # Install version file
ifeq (true,$(shell git rev-parse --is-inside-work-tree 2> /dev/null))
	$(QUELL)sed -e 's|^VERSION_BUILD_METADATA.*$$|VERSION_BUILD_METADATA = $(VERSION_BUILD_METADATA)|' Makefile.Version > "$(dest_package_dir)/Makefile.Version" && \
                chmod 0644 "$(dest_package_dir)/Makefile.Version"
else
	$(QUELL)$(INSTALL_PROGRAM) -m 0644 Makefile.Version "$(dest_package_dir)/Makefile.Version"
endif
	@printf ".\n"

installdirs:
	$(QUELL)$(INSTALL_PROGRAM) -d -m 0755 "$(install_builddir)"
	$(QUELL)$(INSTALL_PROGRAM) -d -m 0755 "$(install_compilerdir)"
	$(QUELL)$(INSTALL_PROGRAM) -d -m 0755 "$(install_linkerdir)"

# targets for setting default system-wide library
install-set-default-to-v%:
	@printf "Setting default $(package_name) to $(package_name)-v$*\n"
	$(QUELL)fl="$(DESTDIR)$(bindir)/$(package_name)-build-config"                               && if test -L "$$fl"; then rm -f "$$fl"; fi && ln -fs "$(package_name)-v$*-build-config" "$$fl"
	$(QUELL)fl="$(DESTDIR)$(bindir)/$(package_name)-collections-management"                     && if test -L "$$fl"; then rm -f "$$fl"; fi && ln -fs "$(package_name)-v$*-collections-management" "$$fl"
	$(QUELL)$(INSTALL_PROGRAM) -d -m 0755 "$(DESTDIR)$(libexecdir)/$(package_name)"
	$(QUELL)fl="$(DESTDIR)$(libexecdir)/$(package_name)/$(package_name)-descriptor-file-match"  && if test -L "$$fl"; then rm -f "$$fl"; fi && ln -fs "$(libexecdir)/$(full_package_name)/$(package_name)-v$*-descriptor-file-match" "$$fl"
	$(QUELL)fl="$(DESTDIR)$(libexecdir)/$(package_name)/$(package_name)-simulator-model"        && if test -L "$$fl"; then rm -f "$$fl"; fi && ln -fs "$(libexecdir)/$(full_package_name)/$(package_name)-v$*-simulator-model" "$$fl"
	$(QUELL)fl="$(DESTDIR)$(includedir)/$(package_name)"       && if test -L "$$fl"; then rm -f "$$fl"; fi && ln -fs "$(package_name)-v$*" "$$fl"
	$(QUELL)fl="$(DESTDIR)$(libdir)/$(package_name)"           && if test -L "$$fl"; then rm -f "$$fl"; fi && ln -fs "$(package_name)-v$*" "$$fl"
	$(QUELL)fl="$(DESTDIR)$(libdir)/lib$(package_name).so" && if test -L "$$fl"; then rm -f "$$fl"; fi && ln -fs "lib$(package_name)-v$*.so" "$$fl"


#
# Main uninstall settings and rules
#
.PHONY: uninstall kim-api-objects-uninstall kim-api-libs-uninstall utils-uninstall config-uninstall

uninstall: config kim-api-objects-uninstall utils-uninstall kim-api-libs-uninstall config-uninstall

# targets involved in "make uninstall"
kim-api-objects-uninstall:
	$(QUELL)$(MAKE) $(MAKE_FLAGS) -C $(srcdir) objects-uninstall

utils-uninstall:
	$(QUELL)$(MAKE) $(MAKE_FLAGS) -C $(srcdir)/utils uninstall

kim-api-libs-uninstall:
	$(QUELL)$(MAKE) $(MAKE_FLAGS) -C $(srcdir) libs-uninstall

config-uninstall:
	@printf "Uninstalling...($(dest_package_dir))................................. KIM_Config files.\n"
        # Make sure the package directory is gone
	$(QUELL)if test -d "$(dest_package_dir)"; then rm -rf "$(dest_package_dir)"; fi
        # Uninstall the rest
	$(QUELL)if test -d "$(DESTDIR)$(includedir)"; then rmdir "$(DESTDIR)$(includedir)" > /dev/null 2>&1 || true; fi
	$(QUELL)if test -d "$(DESTDIR)$(bindir)"; then rmdir "$(DESTDIR)$(bindir)" > /dev/null 2>&1 || true; fi
	$(QUELL)if test -d "$(DESTDIR)$(libexecdir)/$(full_package_name)"; then rmdir "$(DESTDIR)$(bindir)/$(full_package_name)" > /dev/null 2>&1 || true; fi
	$(QUELL)if test -d "$(DESTDIR)$(libexecdir)"; then rmdir "$(DESTDIR)$(bindir)" > /dev/null 2>&1 || true; fi
	$(QUELL)if test -d "$(DESTDIR)$(libdir)"; then rmdir "$(DESTDIR)$(libdir)" > /dev/null 2>&1 || true; fi
	$(QUELL)if test -d "$(DESTDIR)$(exec_prefix)"; then rmdir "$(DESTDIR)$(exec_prefix)" > /dev/null 2>&1 || true; fi
	$(QUELL)if test -d "$(DESTDIR)$(prefix)"; then rmdir "$(DESTDIR)$(prefix)" > /dev/null 2>&1 || true; fi

# targets for unsetting default system-wide library
uninstall-set-default:
	@printf "Removing default $(package_name) settings.\n"
	$(QUELL)fl="$(DESTDIR)$(bindir)/$(package_name)-build-config"                               && if test -L "$$fl"; then rm -f "$$fl"; fi
	$(QUELL)fl="$(DESTDIR)$(bindir)/$(package_name)-collections-management"                     && if test -L "$$fl"; then rm -f "$$fl"; fi
	$(QUELL)fl="$(DESTDIR)$(libexecdir)/$(package_name)/$(package_name)-descriptor-file-match"  && if test -L "$$fl"; then rm -f "$$fl"; fi
	$(QUELL)fl="$(DESTDIR)$(libexecdir)/$(package_name)/$(package_name)-simulator-model"        && if test -L "$$fl"; then rm -f "$$fl"; fi
	$(QUELL)rmdir "$(DESTDIR)$(libexecdir)/$(package_name)" > /dev/null 2>&1 || true
	$(QUELL)fl="$(DESTDIR)$(includedir)/$(package_name)"       && if test -L "$$fl"; then rm -f "$$fl"; fi
	$(QUELL)fl="$(DESTDIR)$(libdir)/$(package_name)"           && if test -L "$$fl"; then rm -f "$$fl"; fi
	$(QUELL)fl="$(DESTDIR)$(libdir)/lib$(package_name).so" && if test -L "$$fl"; then rm -f "$$fl"; fi

########### for internal use ###########
%-making-echo:
	@printf "\n%79s\n" " " | sed -e 's/ /*/g'
	@printf "%-77s%2s\n" "** Building... `printf "$(patsubst %-all,%,$*)" | sed -e 's/@/ /g'`" "**"
	@printf "%79s\n" " " | sed -e 's/ /*/g'
