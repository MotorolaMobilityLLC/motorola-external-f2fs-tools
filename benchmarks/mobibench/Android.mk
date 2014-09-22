LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := mobibench.c
LOCAL_MODULE := mot.mobibench
LOCAL_C_INCLUDES += external/sqlite/dist
LOCAL_SHARED_LIBRARIES := libsqlite \
            libicuuc \
            libicui18n \
            libutils

ifneq ($(TARGET_ARCH),arm)
LOCAL_LDLIBS += -lpthread -ldl
endif
include $(BUILD_EXECUTABLE)
