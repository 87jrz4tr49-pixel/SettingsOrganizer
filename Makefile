THEOS_PACKAGE_SCHEME = rootless
GO_EASY_ON_ME = 1
MODULES = 0

ARCHS = arm64
TARGET = iphone:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SettingsOrganizer
SettingsOrganizer_FILES = Tweak.xm
SettingsOrganizer_CFLAGS = -fobjc-arc -fno-modules

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Preferences"