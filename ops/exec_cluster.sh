#!/bin/bash

USER=root
home=/home/yongfu/scripts
cmd=$1

for i in `cat config|grep ^ALL_NODES|awk '{print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11}'`
do
    host=$i
    echo "job running on "$host
    #ssh -t $USER@$host source $home/$cmd $2
    ssh -t $USER@$host $cmd

done

echo "done."
