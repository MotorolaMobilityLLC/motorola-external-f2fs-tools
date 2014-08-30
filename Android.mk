LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := mkfs/f2fs_format_utils.c mkfs/f2fs_format.c mkfs/f2fs_format_main.c lib/libf2fs.c lib/libf2fs_io.c
LOCAL_MODULE := mkfs.f2fs_arm
LOCAL_MODULE_TAGS := optional
LOCAL_REQUIRED_MODULES := $(LOCAL_MODULE)
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := fsck/fsck.c fsck/dump.c fsck/mount.c fsck/main.c lib/libf2fs.c lib/libf2fs_io.c
LOCAL_MODULE := fsck.f2fs
LOCAL_MODULE_TAGS := optional
LOCAL_REQUIRED_MODULES := $(LOCAL_MODULE)
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := fsck/fsck.c fsck/dump.c fsck/mount.c fsck/main.c lib/libf2fs.c lib/libf2fs_io.c
LOCAL_MODULE := dump.f2fs
LOCAL_MODULE_TAGS := optional
LOCAL_REQUIRED_MODULES := $(LOCAL_MODULE)
include $(BUILD_EXECUTABLE)
