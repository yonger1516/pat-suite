#!/bin/bash
export INPUT_HDFS=HiBench/Terasort/Input
export OUTPUT_HDFS=HiBench/Terasort/Output

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

        run_spark_terasort

        tempdir=terasort_`date +%m%d_%T`_java
        cp -r $HIBENCH_BASE/report/terasort/spark/java $HIBENCH_BASE/../result/$tempdir
        cp -r $HIBENCH_BASE/../result/$tempdir /tmp/result/
        hadoop dfs -du $INPUT_HDFS/..
        hadoop dfs -du $INPUT_HDFS/.. >> /tmp/stdout
        cp /tmp/stdout /tmp/result/
        tar czf /tmp/result.tgz /tmp/result/

        echo DataSize = $SIZE bytes
        echo SortTime = $DURATION seconds
        echo Throughput = `echo "scale=2; $SIZE / $DURATION / 1024 / 1024"|bc` MB/sec
        echo [`date +"%Y-%m-%d %T"`] ==================== TeraSort ======================

        echo $DURATION > $HIBENCH_BASE/../result/$tempdir/duration.txt
        echo $DURATION >> $HIBENCH_BASE/../result/duration.txt
}

run_spark_terasort(){
        workload_folder=$HIBENCH_BASE/workloads/terasort/spark/java/bin
        workload_folder=`cd "$workload_folder"; pwd`
        workload_root=${workload_folder}/../../..
        . "${workload_root}/../../bin/functions/load-bench-config.sh"

        enter_bench JavaSparkTerasort ${workload_root} ${workload_folder}
        show_bannar start

        rmr-hdfs $OUTPUT_HDFS || true

        #SIZE=`dir_size $INPUT_HDFS`
        echo [`date +"%Y-%m-%d %T"`] Starting TeraSort...
        START_TIME=`timestamp`
        echo START_TIME=$START_TIME
        run-spark-job com.intel.sparkbench.terasort.JavaTeraSort $INPUT_HDFS $OUTPUT_HDFS
        echo [`date +"%Y-%m-%d %T"`] Run completed.
        END_TIME=`timestamp`
        echo END_TIME=$END_TIME
        DURATION=$(((END_TIME-START_TIME)/1000))
        echo DURATION=$DURATION

        gen_report ${START_TIME} ${END_TIME} ${SIZE} >>/tmp/stdout
        show_bannar finish
        leave_bench
}

changePara(){
	sed -i -e "s/^hibench.default.map.parallelism.*/hibench.default.map.parallelism $1/" $HIBENCH_BASE/conf/99-user_defined_properties.conf
	sed -i -e "s/^hibench.default.shuffle.parallelism.*/hibench.default.shuffle.parallelism $2/" $HIBENCH_BASE/conf/99-user_defined_properties.conf
	sed -i -e "s/^hibench.yarn.executor.num.*/hibench.yarn.executor.num $3/" $HIBENCH_BASE/conf/99-user_defined_properties.conf
	sed -i -e "s/^hibench.yarn.executor.cores.*/hibench.yarn.executor.cores $4/" $HIBENCH_BASE/conf/99-user_defined_properties.conf
	sed -i -e "s/^spark.executor.memory.*/spark.executor.memory $5/" $HIBENCH_BASE/conf/99-user_defined_properties.conf
	echo $1 $2 $3 $4 $5 >> $HIBENCH_BASE/../result/duration.txt
	echo $1 $2 $3 $4 $5
}

#prepare
#changePara 720 1080 72 8 15G
changePara 1435 1435 80 5 11g
shoot
