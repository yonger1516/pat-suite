#!/bin/bash
export INPUT_HDFS=HiBench/Terasort/Input

export JAVA_HOME=/usr/java/jdk1.7.0_67-cloudera/
export HADOOP_HOME=/opt/cloudera/parcels/CDH/lib/hadoop
export HADOOP_EXECUTABLE=$HADOOP_HOME/bin/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/
export MAPRED_EXECUTABLE=/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/bin/mapred
export HADOOP_EXAMPLES_JAR=/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar

HIBENCH_BASE=/root/benchmark/spark/HiBench/


prepare(){
	echo -------------------------------------------------
	echo 0 Prepare sort
	echo -------------------------------------------------
	$HIBENCH_BASE/workloads/terasort/prepare/prepare.sh
}

terasort_prepare(){
        workload_folder=$HIBENCH_BASE/workloads/terasort/prepare
        #workload_folder=`cd "$workload_folder"; pwd`
        workload_root=${workload_folder}/..
        . "${workload_root}/../../bin/functions/load-bench-config.sh"

        enter_bench HadoopPrepareTerasort ${workload_root} ${workload_folder}
        show_bannar start

        rmr-hdfs $INPUT_HDFS || true
        START_TIME=`timestamp`
        run-hadoop-job ${HADOOP_EXAMPLES_JAR} teragen \
            -D${MAP_CONFIG_NAME}=${NUM_MAPS} \
            -D${REDUCER_CONFIG_NAME}=${NUM_REDS} \
            ${DATASIZE} ${INPUT_HDFS}
        END_TIME=`timestamp`
        DURATION=$(((END_TIME-START_TIME)/1000))

        echo [`date +"%Y-%m-%d %T"`] Run completed.
        SIZE=`$HADOOP_EXECUTABLE fs -du -s $INPUT_HDFS |awk '{print $1}'`
        echo DataSize = $SIZE bytes
        echo GenTime = $DURATION seconds
        echo Throughput = `echo "scale=2; $SIZE / $DURATION / 1024 / 1024"|bc` MB/sec

        show_bannar finish
        leave_bench
}

terasort_prepare
