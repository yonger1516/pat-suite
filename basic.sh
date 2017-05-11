#!/bin/bash

get_hosts(){
    hosts=`cat config|grep ^ALL_NODES|awk '{print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11}'`
    echo $hosts 
}
