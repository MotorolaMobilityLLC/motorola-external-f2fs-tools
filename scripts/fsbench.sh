#!/system/bin/sh

DIR=/mnt/obb
TEST=/data/fstest/
TESTFILE=testfile
SIZE_2M=$((2*1024))
SIZE_1G=$((1024*1024))

rm $TEST/*.db0
rm $TEST/*.wal
rm -rf $TEST
mkdir -p $TEST
sync

echo "==============================="
echo "| 1. iozone - quark  (32GB)   |"
echo "| 2. iozone - quark  (64GB)   |"
echo "| 3. iozone - surnia (8GB)    |"
echo "| 4. iozone - titan  (16GB)   |"
echo "| 5. clean tests              |"
echo "| 6. mobibench (persist)      |"
echo "| 7. mobibench (j_off:atomic) |"
echo "| 8. mobibench_shell (j_off)  |"
echo "==============================="

if [ "$1" = "" ]
then
	echo -n "Which one? "
	read num
else
	num=$1
fi

case "$num" in
1)
	USER_SIZE=21		# GB for quark Sandisk 29,820 MB
	T=1
	;;
2)
	USER_SIZE=51		# GB for quark Sandisk 59,640 MB
	T=1
	;;
3)
	USER_SIZE=3		# GB for surnia Hynix 7,456 MB
	T=1
	;;
4)
	USER_SIZE=11		# GB for titan Samsung 14,910 MB
	T=1
	;;
5)
	T=2
	;;
6)
	T=3
	;;
7)
	T=4
	;;
8)
	T=5
	;;
*)
	echo "No choice"
	exit
	;;
esac

__stat()
{
	df
	cat /sys/kernel/debug/f2fs/status
}

__init()
{
	sync
	echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
	echo 3 > /proc/sys/vm/drop_caches
	echo 0 > /sys/block/mmcblk0/queue/read_ahead_kb

	DM=/sys/block/dm-0/queue/read_ahead_kb

	if [ -f "$DM" ]
	then
		echo 0 > /sys/block/dm-0/queue/read_ahead_kb
	fi
#	echo row > /sys/block/mmcblk0/queue/scheduler
}

__seq_write()
{
	mot.iozone -+s $2 -e -w -s $3 -r 4 -f $1 -i 0 -+n
}

__seq_read()
{
	mot.iozone -+s $2 -e -w -s $3 -r 4 -f $1 -i 1 -+n
}

__rand_rw()
{
	mot.iozone -+s $2 $4 -e -w -s $3 -r 4 -f $1 -i 2 -+n
}

__run_iozone()
{
	__init
	__seq_write $TEST/$TESTFILE-$1 "" $SIZE_1G
	__init
	__seq_read $TEST/$TESTFILE-$1 "" $SIZE_1G
	__init
	__rand_rw $TEST/$TESTFILE-$1 "" $SIZE_1G "$2"
}

__fill_2G()
{
	mkdir -p $TEST/$1
	sync

	__seq_write "$TEST/$1/dirty-$SIZE_1G" "" $SIZE_1G >/dev/null 2>/dev/null

	j=1
	while [ $j -le 512 ]
	do
		__seq_write "$TEST/$1/dirty-$SIZE_2M-$j" "" $SIZE_2M >/dev/null 2>/dev/null
		j=$(($j + 1))
	done
}

__rand_2M()
{
	j=1
	while [ $j -le 512 ]
	do
		__rand_rw "$TEST/$1/dirty-$SIZE_2M-$j" "-+b" $SIZE_2M "-+a 4" >/dev/null 2>/dev/null
		j=$(($j + 1))
	done
}

__make_dirty()
{
	num=$((USER_SIZE / 2))

	i=1
	echo -ne "Filling [$i / $num] (1G and 512 * 2MB files)"
	while [ $i -le $num ]
	do
		echo -ne "\rFilling [$i / $num] (1G and 512 * 2MB files)"
		__fill_2G $i
		i=$(($i + 1))
	done
	echo ""

	i=1
	echo -ne "Random writes [$i / $num] (1GB random writes on 512 * 2MB files)"
	while [ $i -le $num ]
	do
		echo -ne "\rRandom writes [$i / $num] (1GB random writes on 512 * 2MB files)"
		__rand_2M $i
		i=$(($i + 1))
	done
	echo ""
}

__rm_1G()
{
	if [ "$1" = "dirty" ]
	then
		rm $TEST/$2/dirty-$SIZE_1G
		rm $TEST/$2/dirty-$SIZE_2M-1
		rm $TEST/$2/dirty-$SIZE_2M-2
		rm $TEST/$2/dirty-$SIZE_2M-3
		rm $TEST/$2/dirty-$SIZE_2M-4
		rm $TEST/$2/dirty-$SIZE_2M-5
	fi
}

__do_test()
{
	__rm_1G $1 1
	__run_iozone $1 ""

	if [ $USER_SIZE -gt 6 ]
	then
		__rm_1G $1 2
		__run_iozone $1-2 "-+a 256"
		__rm_1G $1 3
		__run_iozone $1-3 "-+a 64"
		__rm_1G $1 4
		__run_iozone $1-4 "-+a 16"
		__rm_1G $1 5
		__run_iozone $1-5 "-+a 4"
	fi

	i=1
	while [ $i -le 5 ]
	do
		mkdir -p $TEST/mobitest-$1-$i
		__init
		mot.mobibench -d 0 -n 10000 -j 2 -s 2 -p $TEST/mobitest-$1-$i
		i=$(($i + 1))
	done
	i=1
	while [ $i -le 5 ]
	do
		mkdir -p $TEST/mobitest2-$1-$i
		__init
		mot.mobibench -d 0 -n 10000 -j 5 -s 2 -p $TEST/mobitest2-$1-$i
		i=$(($i + 1))
	done
}

case $T in
1)
	# clean state
	__stat
	__do_test clean
	__stat

	# dirty state
	__make_dirty

	__stat
	__do_test dirty
	__stat
	;;
2)
	# clean state
	__stat
	__do_test clean
	__stat
	;;
3)
	mot.mobibench -d 0 -n 10000 -j 2 -s 2 -p $TEST
	;;
4)
	mot.mobibench -d 0 -n 10000 -j 5 -s 2 -p $TEST
	;;
5)
	$DIR/mobibench_shell -d 0 -n 10000 -j 5 -s 2 -p $TEST
	;;
*)
	echo "No choice"
	;;
esac
