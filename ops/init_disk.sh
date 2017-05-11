#!/bin/bash

#PASSWORD=8400530bwm

for x in {g..g}
do
     sudo parted /dev/sd$x <<EOF 
mklabel gpt
mkpart primary 1G -1
quit
EOF
    # sudo umount /dev/sd${x}1
    sudo mkfs.ext4 /dev/sd$x"1"
    echo "/dev/sd${x}1 /data/yarn/nm-$x ext4 user,defaults,noexec,nosuid,nodev,noatime,nodelalloc 0 0"|sudo tee --append /etc/fstab
    
    sudo mkdir -p /data/${x}
    sudo mount /dev/sd${x}1 /data/${x} -o rw,noexec,nosuid,nodev,noatime,nodelalloc
done

for x in {b..f}
do
     sudo parted /dev/sd$x <<EOF 
mklabel gpt
mkpart primary 1G -1
quit
EOF
    sudo mkfs.ext4 /dev/sd$x"1"
    sudo mkdir -p /opt/cdh-hdfs-storage/jbod-$x
    sudo mount /dev/sd${x}1 /opt/cdh-hdfs-storage/jbod-$x -o rw,noexec,nosuid,nodev,noatime,nodelalloc
    echo "/dev/sd${x}1 /opt/cdh-hdfs-storage/jbod-$x ext4 user,defaults,noexec,nosuid,nodev,noatime,nodelalloc 0 0"|sudo tee --append /etc/fstab
    #sudo rm -rf /opt/cdh-hdfs-storage/jbod-$x/*
    echo "done on sd"${x}
done


