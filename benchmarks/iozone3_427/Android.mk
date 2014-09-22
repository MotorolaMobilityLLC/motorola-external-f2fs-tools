LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_CFLAGS := -O3 -DNO_THREADS -Dunix -DHAVE_ANSIC_C -DHAVE_PREAD -DNAME='"linux-arm"' -Dlinux
LOCAL_LDLIBS += -lrt

LOCAL_SRC_FILES:= iozone.c libbif.c
LOCAL_MODULE := mot.iozone
include $(BUILD_EXECUTABLE)
