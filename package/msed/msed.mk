################################################################################
#
# msed
#
################################################################################

MSED_VERSION = e38a16da6fbd3f92c23c37fc28a4d0e00a9c0602
#MSED_SOURCE = 
MSED_SITE = git://github.com/r0m30/msed.git
MSED_LICENSE = GPLv3+
MSED_LICENSE_FILES = msed/Copyright.txt msed/LICENSE.txt
#MSED_INSTALL_STAGING = yes
#MSED_CONFIG_SCRIPTS =
MSED_DEPENDENCIES = ncurses

define MSED_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		CC="$(TARGET_CC)" \
		CCC="$(TARGET_CXX)" \
		CXX="$(TARGET_CXX)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		NM="$(TARGET_NM)" \
		RANLIB="$(TARGET_RANLIB)" \
		AS="$(TARGET_AS)" \
		CONF="Release_i686"

	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/LinuxPBA \
		CC="$(TARGET_CC)" \
		CCC="$(TARGET_CXX)" \
		CXX="$(TARGET_CXX)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		NM="$(TARGET_NM)" \
		RANLIB="$(TARGET_RANLIB)" \
		AS="$(TARGET_AS)" \
		CONF="Release"
endef

define MSED_INSTALL_TARGET_CMDS
	install -m755 $(@D)/dist/Release_i686/msed $(TARGET_DIR)/usr/bin/msed
	install -m755 $(@D)/LinuxPBA/dist/Release/GNU-Linux-x86/linuxpba $(TARGET_DIR)/usr/bin/linuxpba
endef

$(eval $(generic-package))
