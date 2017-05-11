#!/bin/bash

# This script is used to run TeraGen workload from the ResourceManager node of a YARN cluster, either physical or virtual.
# This script should have no dependency on anything other than the Haddop environment.

#scalefactor=1000000000 #(100GB)
#scalefactor=2000000000 #(200GB)
#scalefactor=5000000000 #(500GB)
scalefactor=10000000000 #(1TB)
#scalefactor=20000000000 #(2TB)
#scalefactor=30000000000 #(3TB)
#scalefactor=50000000000 #(5TB)

INPUT_HDFS=HiBench/Terasort/Input

export JAVA_HOME=/usr/java/jdk1.7.0_67-cloudera/
export HADOOP_HOME=/opt/cloudera/parcels/CDH/lib/hadoop
export HADOOP_EXECUTABLE=$HADOOP_HOME/bin/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/
export MAPRED_EXECUTABLE=/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/bin/mapred
export HADOOP_EXAMPLES_JAR=/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar

PARAMS=""
PARAMS="$PARAMS -Dmapreduce.map.output.compress=true"
PARAMS="$PARAMS -Dmapreduce.reduce.shuffle.parallelcopies=30"
PARAMS="$PARAMS -Dmapreduce.input.fileinputformat.split.maxsize=1073741824"
#PARAMS="$PARAMS -Dmapreduce.input.fileinputformat.split.minsize=536870912"
PARAMS="$PARAMS -Dmapreduce.map.memory.mb=2400"
PARAMS="$PARAMS -Dmapreduce.map.java.opts=-Xmx2100m"
#PARAMS="$PARAMS -Dmapreduce.map.memory.mb=8192"
#PARAMS="$PARAMS -Dmapreduce.map.java.opts=-Xmx6552m"
PARAMS="$PARAMS -Dmapreduce.task.io.sort.mb=1800"
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
PARAMS="$PARAMS -Dmapreduce.job.maps=612"

echo [`date +"%Y-%m-%d %T"`] ==================== TeraGen ======================
echo [`date +"%Y-%m-%d %T"`] Scale Factor: $scalefactor 
echo [`date +"%Y-%m-%d %T"`] Output directory: $INPUT_HDFS
echo [`date +"%Y-%m-%d %T"`] Removing any existing output data...
$HADOOP_EXECUTABLE fs -rm -r -skipTrash $INPUT_HDFS >/dev/null 2>&1

echo [`date +"%Y-%m-%d %T"`] Starting TeraGen...

START=$(date +%s)
set -x
$HADOOP_EXECUTABLE jar $HADOOP_EXAMPLES_JAR teragen $PARAMS $scalefactor $INPUT_HDFS
set +x
END=$(date +%s)
DURATION=$((END-START))

echo [`date +"%Y-%m-%d %T"`] Run completed.
SIZE=`$HADOOP_EXECUTABLE fs -du -s $INPUT_HDFS |awk '{print $1}'` 
echo DataSize = $SIZE bytes
echo GenTime = $DURATION seconds
echo Throughput = `echo "scale=2; $SIZE / $DURATION / 1024 / 1024"|bc` MB/sec
echo [`date +"%Y-%m-%d %T"`] ==================== TeraGen ======================
