#!/bin/bash

loop=1
if [ "$2" != "" ]
then
    loop=$2
fi
echo "loop = $loop"

clean=0
if [ "$3" != "" ]
then
    clean=$3
fi
echo "clean = $clean"

rm_host="mars1"
for((i=0;i<$loop;i++))
do
	source ./workload_prepare.sh $1 $clean
	./pat run ${runid}

	#ssh root@bm9 "tar -czf /tmp/cm-conf.tgz /var/run/cloudera-scm-agent/process"
	#scp root@bm9:/tmp/cm-conf.tgz ./results/${runid}/conf/
	scp root@$rm_host:/tmp/result.tgz ./results/${runid}/
	job_id=`grep "mapreduce.Job: Running job: " results/$runid/jobhistory/stdout | awk '{print $7}'`
	echo `date '+%D'` $runid $workload `grep "SortTime" results/$runid/jobhistory/stdout | awk '{print $3}'` `grep "Throughput" results/$runid/jobhistory/stdout | awk '{print $3}'` >> ./results/results.txt
	echo $runid $workload SortTime=`grep "SortTime" results/$runid/jobhistory/stdout | awk '{print $3}'`seconds Throughput=`grep "Throughput =" results/$runid/jobhistory/stdout | awk '{print $3}'`MB/sec
	cp ./workload/$1.sh results/$runid/
	echo "*****************loop $i done******************"
#	sleep 30
done

