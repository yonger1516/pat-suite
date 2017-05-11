#!/bin/bash
source basic.sh

for i in `get_hosts`
do
	# delete all partitions, and dd 1GB to the head of disks,
	# and then fdisk the disks to create partitions again.
        for x in {b..g}
	do
		ssh root@$i " \
			(echo d; echo w) | fdisk /dev/sd$x;
			dd if=/dev/zero of=/dev/sd$x bs=1M count=1000;
			(echo n; echo p; echo 1; echo ; echo ; echo t; echo ee; echo w) | fdisk /dev/sd$x;"
	done
done
