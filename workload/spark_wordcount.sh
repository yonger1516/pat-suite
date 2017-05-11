#!/bin/bash
#export INPUT_HDFS=HiBench/Terasort/Input
#export OUTPUT_HDFS=HiBench/Terasort/Output
#export INPUT_HDFS=dtap://TenantStorage/Terasort/Input-1TB
#export OUTPUT_HDFS=dtap://TenantStorage/Terasort/Output

export JAVA_HOME=/usr/java/jdk1.7.0_67-cloudera/
export HADOOP_HOME=/opt/cloudera/parcels/CDH/lib/hadoop
export HADOOP_EXECUTABLE=$HADOOP_HOME/bin/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/
#export MAPRED_EXECUTABLE=/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/bin/mapred
#export HADOOP_EXAMPLES_JAR=/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar

#lang=java
HIBENCH_BASE=/home/bluedata/spark/HiBench


prepare(){
	echo -------------------------------------------------
	echo 0 Prepare sort
	echo -------------------------------------------------
	$HIBENCH_BASE/workloads/wordcount/prepare/prepare.sh
}

changeSize(){
	sed -i -e "s/^hibench.scale.profile.*/hibench.scale.profile $1/" $HIBENCH_BASE/conf/99-user_defined_properties.conf
}

shoot(){
	echo [`date +"%Y-%m-%d %T"`] ==================== TeraSort ======================
	#echo [`date +"%Y-%m-%d %T"`] RUNID=$runid
	echo [`date +"%Y-%m-%d %T"`] Input directory: $INPUT_HDFS
	SIZE=`$HADOOP_EXECUTABLE fs -du -s $INPUT_HDFS |awk '{print $1}'`
	echo [`date +"%Y-%m-%d %T"`] Input data size: $SIZE bytes.
	echo [`date +"%Y-%m-%d %T"`] Output directory: $OUTPUT_HDFS
	echo [`date +"%Y-%m-%d %T"`] Removing any existing output data...
	$HADOOP_EXECUTABLE fs -rm -r -skipTrash $OUTPUT_HDFS >/dev/null 2>&1
	rm -rf /tmp/result/
	echo [`date +"%Y-%m-%d %T"`] Starting TeraSort...
	START=$(date +%s)
	set -x

	#$HIBENCH_BASE/workloads/wordcount/spark/java/bin/run.sh > /tmp/stdout 1>>/tmp/stdout 2>>/tmp/stdout
	$HIBENCH_BASE/workloads/wordcount/spark/java/bin/run.sh > /tmp/stdout 2>>/tmp/stdout
	set +x
	END=$(date +%s)
	DURATION=$((END-START))

	cp -r $HIBENCH_BASE/report/wordcount/spark/java $HIBENCH_BASE/../result/wordcount_`date +%m%d_%T`_java
	cp -r $HIBENCH_BASE/../result/wordcount_`date +%m%d_%T`_java /tmp/result/
        hadoop dfs -du $INPUT_HDFS/..
        hadoop dfs -du $INPUT_HDFS/.. >> /tmp/stdout
	cp /tmp/stdout /tmp/result/
	tar czf /tmp/result.tgz /tmp/result/

	echo [`date +"%Y-%m-%d %T"`] Run completed.
	echo DataSize = $SIZE bytes
	echo SortTime = $DURATION seconds
	echo Throughput = `echo "scale=2; $SIZE / $DURATION / 1024 / 1024"|bc` MB/sec
	echo [`date +"%Y-%m-%d %T"`] ==================== TeraSort ======================

	echo $DURATION > $HIBENCH_BASE/../result/wordcount_`date +%m%d_%T`_java/duration.txt
	echo $DURATION >> $HIBENCH_BASE/../result/duration.txt
}

changePara(){
	sed -i -e "s/^hibench.default.map.parallelism.*/hibench.default.map.parallelism $1/" $HIBENCH_BASE/conf/99-user_defined_properties.conf
	sed -i -e "s/^hibench.default.shuffle.parallelism.*/hibench.default.shuffle.parallelism $2/" $HIBENCH_BASE/conf/99-user_defined_properties.conf
	sed -i -e "s/^hibench.yarn.executor.num.*/hibench.yarn.executor.num $3/" $HIBENCH_BASE/conf/99-user_defined_properties.conf
	sed -i -e "s/^hibench.yarn.executor.cores.*/hibench.yarn.executor.cores $4/" $HIBENCH_BASE/conf/99-user_defined_properties.conf
	sed -i -e "s/^spark.executor.memory.*/spark.executor.memory $5/" $HIBENCH_BASE/conf/99-user_defined_properties.conf
	echo $1 $2 $3 $4 $5 >> $HIBENCH_BASE/../result/duration.txt
}

#prepare
changePara 720 612 36 8 15G
#changePara 720 612 72 8 15G
#changePara 720 720 72 4 8G
shoot

