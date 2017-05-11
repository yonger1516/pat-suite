#!/bin/bash

echo [$HOSTNAME][$0][`date +"%Y-%m-%d %T"`] Launching the workload...

# physical cluster
ssh root@$yarn_rm_node "cd /tmp/pat_workload; ./${workload} 2>&1"

