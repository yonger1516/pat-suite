#!/bin/bash

# This script is used to run TeraSort workload from the ResourceManager node of a YARN cluster, either physical or virtual.
# This script should have no dependency on anything other than the Haddop environment.

INPUT_HDFS=/user/root/benchmarks/TestDFSIO/io_data


export JAVA_HOME=/usr/java/jdk1.7.0_67-cloudera/
export HADOOP_HOME=/opt/cloudera/parcels/CDH/lib/hadoop
export HADOOP_EXECUTABLE=$HADOOP_HOME/bin/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/
export MAPREDUCE_HOME=/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce
export HADOOP_TEST_JAR=$MAPREDUCE_HOME/hadoop-mapreduce-client-jobclient-2.6.0-cdh5.7.0-tests.jar
export MAPRED_EXECUTABLE=$MAPREDUCE_HOME/bin/mapred
export HADOOP_EXAMPLES_JAR=$MAPREDUCE_HOME/hadoop-mapreduce-examples.jar



PARAMS=""
PARAMS="$PARAMS -Dmapreduce.map.output.compress=true"
PARAMS="$PARAMS -Dmapreduce.map.memory.mb=2048"
PARAMS="$PARAMS -Dmapreduce.map.java.opts=-Xmx1638m"
PARAMS="$PARAMS -Dmapreduce.task.io.sort.mb=768"
PARAMS="$PARAMS -Dmapreduce.task.io.sort.factor=100"
PARAMS="$PARAMS -Dmapreduce.map.sort.spill.percent=0.99"
PARAMS="$PARAMS -Dmapreduce.reduce.memory.mb=2048"
PARAMS="$PARAMS -Dmapreduce.reduce.java.opts=-Xmx1638m"
PARAMS="$PARAMS -Dyarn.app.mapreduce.am.resource.mb=2048"
PARAMS="$PARAMS -Dyarn.app.mapreduce.am.command-opts=-Xmx1638m"
PARAMS="$PARAMS -Dmapreduce.job.reduce.slowstart.completedmaps=0.90"
PARAMS="$PARAMS -Dmapreduce.reduce.shuffle.merge.percent=0.80"
PARAMS="$PARAMS -Dmapred.map.tasks.speculative.execution=false"
PARAMS="$PARAMS -Dmapred.reduce.tasks.speculative.execution=false"
PARAMS="$PARAMS -Dtest.build.data=/user/root/benchmarks/TestDFSIO"

nrFiles=535
fileSize=`expr 1000000000000 / $nrFiles / 1024`

echo [`date +"%Y-%m-%d %T"`] ==================== TestDFSIO ======================
#echo [`date +"%Y-%m-%d %T"`] RUNID=$runid
#echo [`date +"%Y-%m-%d %T"`] Output directory: $OUTPUT_HDFS
#echo [`date +"%Y-%m-%d %T"`] Removing any existing output data...
#$HADOOP_EXECUTABLE jar $HADOOP_TEST_JAR TestDFSIO -Dfs.defaultFS=dtap://TenantStorage -clean 
echo [`date +"%Y-%m-%d %T"`] Starting ...

START=$(date +%s)
set -x
$HADOOP_EXECUTABLE jar $HADOOP_TEST_JAR TestDFSIO $PARAMS  -read -nrFiles $nrFiles -size ${fileSize}KB 
set +x
END=$(date +%s)
DURATION=$((END-START))
SIZE=`$HADOOP_EXECUTABLE fs -du -s $INPUT_HDFS |awk '{print $1}'`


echo [`date +"%Y-%m-%d %T"`] Run completed. 
echo DataSize = $SIZE bytes
echo SortTime = $DURATION seconds
echo Throughput = `echo "scale=2; $SIZE / $DURATION / 1024 / 1024"|bc` MB/sec
echo [`date +"%Y-%m-%d %T"`] ==================== TestDFSIO ======================
