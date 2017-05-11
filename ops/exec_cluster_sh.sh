#!/bin/bash

USER=root
home=/home/yongfu/scripts
cmd=$1
source basic.sh

exec_cmd(){ 
    ssh -t $USER@$1 $2
}


for i in `get_hosts`
do
    host=$i
    echo "job running on "$host
    #ssh -t $USER@$host source $home/$cmd $2
    exec_cmd $i "mkdir -p /mnt/cloudera/scripts"
    exec_cmd $i "mount -t nfs 172.16.0.1:/home/bluedata/cloudera/scripts/ /mnt/cloudera/scripts"
    exec_cmd $i "source /mnt/cloudera/scripts/$cmd"

done


echo "done."
