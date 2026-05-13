export TARGET = iphone:clang:18.6:14.0
export SDK_PATH = $(THEOS)/sdks/iPhoneOS18.6.sdk/
export SYSROOT = $(SDK_PATH)
export ARCHS = arm64

export ADDITIONAL_CFLAGS = -I$(THEOS_PROJECT_DIR)/Tweaks/RemoteLog -I$(THEOS_PROJECT_DIR)/Tweaks

ifneq ($(JAILBROKEN),1)
export DEBUGFLAG = -ggdb -Wno-unused-command-line-argument -L$(THEOS_OBJ_DIR) -F$(_THEOS_LOCAL_DATA_DIR)/$(THEOS_OBJ_DIR_NAME)/install/Library/Frameworks
MODULES = jailed
endif
PACKAGE_NAME = YTLitePlus
PACKAGE_VERSION = X.X.X-X.X

INSTALL_TARGET_PROCESSES = YouTube
TWEAK_NAME = YTLitePlus
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube

YTLitePlus_FILES = YTLitePlus.xm $(shell find Source -name '*.xm' -o -name '*.x' -o -name '*.m')
YTLitePlus_FRAMEWORKS = UIKit Security
YTLitePlus_INJECT_DYLIBS = Tweaks/YTLite/var/jb/Library/MobileSubstrate/DynamicLibraries/YTLite.dylib
YTLitePlus_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unsupported-availability-guard -Wno-unused-but-set-variable -DTWEAK_VERSION=$(PACKAGE_VERSION) $(EXTRA_CFLAGS)
YTLitePlus_USE_FISHHOOK = 0
YTLitePlus_EMBED_BUNDLES = $(wildcard Bundles/*.bundle)
YTLitePlus_EMBED_EXTENSIONS = $(wildcard Extensions/*.appex)
YTLitePlus_IPA = ./tmp/Payload/YouTube.app

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

FINALPACKAGE = 1
REMOVE_EXTENSIONS = 1
CODESIGN_IPA = 0

YTLITE_PATH = Tweaks/YTLite
YTLITE_VERSION ?= $(shell curl -s https://api.github.com/repos/dayanch96/YTLite/releases/latest | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')
ifeq ($(YTLITE_VERSION),)
$(error Failed to fetch latest YTLite version from GitHub API)
endif
YTLITE_DEB = $(YTLITE_PATH)/com.dvntm.ytlite_$(YTLITE_VERSION)_iphoneos-arm64.deb
YTLITE_DYLIB = $(YTLITE_PATH)/var/jb/Library/MobileSubstrate/DynamicLibraries/YTLite.dylib
YTLITE_BUNDLE = $(YTLITE_PATH)/var/jb/Library/Application\ Support/YTLite.bundle

internal-clean::
	@rm -rf $(YTLITE_PATH)/*

ifneq ($(JAILBROKEN),1)
before-all::
	@if [[ ! -f $(YTLITE_DEB) ]]; then \
		rm -rf $(YTLITE_PATH)/*; \
	fi
before-all::
	@if [[ ! -f $(YTLITE_DEB) ]]; then \
		curl -s -L "https://github.com/dayanch96/YTLite/releases/download/v$(YTLITE_VERSION)/com.dvntm.ytlite_$(YTLITE_VERSION)_iphoneos-arm64.deb" -o $(YTLITE_DEB); \
	fi; \
	if [[ ! -f $(YTLITE_DYLIB) || ! -d $(YTLITE_BUNDLE) ]]; then \
		tar -xf $(YTLITE_DEB) -C $(YTLITE_PATH); tar -xf $(YTLITE_PATH)/data.tar* -C $(YTLITE_PATH); \
	fi;
endif
