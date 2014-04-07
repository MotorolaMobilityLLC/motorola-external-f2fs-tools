/**
 * libf2fs.c
 *
 * Copyright (c) 2013 Samsung Electronics Co., Ltd.
 *             http://www.samsung.com/
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */
#define _LARGEFILE64_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <mntent.h>
#include <time.h>
#include <sys/stat.h>
#include <sys/mount.h>
#include <sys/ioctl.h>
#include <linux/hdreg.h>
#include <linux/fs.h>

#include <f2fs_fs.h>

struct f2fs_configuration config;

/*
 * IO interfaces
 */
int dev_read(void *buf, __u64 offset, size_t len)
{
	if (lseek64(config.fd, (off64_t)offset, SEEK_SET) < 0)
		return -1;
	if (read(config.fd, buf, len) < 0)
		return -1;
	return 0;
}

int dev_write(void *buf, __u64 offset, size_t len)
{
	if (lseek64(config.fd, (off64_t)offset, SEEK_SET) < 0)
		return -1;
	if (write(config.fd, buf, len) < 0)
		return -1;
	return 0;
}

int dev_read_block(void *buf, __u64 blk_addr)
{
	return dev_read(buf, blk_addr * F2FS_BLKSIZE, F2FS_BLKSIZE);
}

int dev_read_blocks(void *buf, __u64 addr, __u32 nr_blks)
{
	return dev_read(buf, addr * F2FS_BLKSIZE, nr_blks * F2FS_BLKSIZE);
}
