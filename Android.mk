# Copyright 2008 Texas Instruments
#
#Author(s) Mikkel Christensen (mlc@ti.com) and Ulrik Bech Hald (ubh@ti.com)

#
LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE_TAGS:= optional
LOCAL_MODULE:= gsm0710muxd

LOCAL_SRC_FILES:= \
	src/gsm0710muxd.c \

LOCAL_SHARED_LIBRARIES := libcutils

	# for asprinf

LOCAL_CFLAGS := -DMUX_ANDROID

# Setting flags for android lollipop (5.x.x)
ifneq ($(shell echo '$(PLATFORM_VERSION)' | grep '^5'),)
LOCAL_CFLAGS += -DANDROID_LP
endif

# Setting flags for android marshmallow (6.x.x)
ifneq ($(shell echo '$(PLATFORM_VERSION)' | grep '^6'),)
LOCAL_CFLAGS += -DANDROID_MM
endif

# Setting flags for android Nougat (7.x.x)
ifneq ($(shell echo '$(PLATFORM_VERSION)' | grep '^7'),)
LOCAL_CFLAGS += -DANDROID_NG
endif

# Setting flags for android Oreo (8.0.x)
ifneq ($(shell echo '$(PLATFORM_VERSION)' | grep '^8.0'),)
LOCAL_CFLAGS += -DANDROID_OO
LOCAL_LDLIBS := -llog
endif

# Setting flags for android Oreo (8.1.x)
ifneq ($(shell echo '$(PLATFORM_VERSION)' | grep '^8.1'),)
LOCAL_CFLAGS += -DANDROID_OO
LOCAL_LDLIBS := -llog
LOCAL_STATIC_LIBRARIES := libcutils
LOCAL_SHARED_LIBRARIES := libutils liblog
endif

# Setting flags for Android Pie (9.x.x) , Android (10.x.x), Android (11.x.x) and Android (12.x.x)
ifneq ($(shell echo '$(PLATFORM_VERSION)' | grep '^9\|^10\|^11\|^12'),)
LOCAL_CFLAGS += -DANDROID_PI
LOCAL_LDLIBS := -llog
LOCAL_STATIC_LIBRARIES := libcutils
LOCAL_SHARED_LIBRARIES := libutils liblog
LOCAL_VENDOR_MODULE:= true
endif

#LOCAL_LDLIBS := -lpthread


include $(BUILD_EXECUTABLE)




