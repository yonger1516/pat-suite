#!/bin/bash

# This script is used to run TeraSort workload from the ResourceManager node of a YARN cluster, either physical or virtual.
# This script should have no dependency on anything other than the Haddop environment.

#INPUT_HDFS=Terasort/Input-1TB
#OUTPUT_HDFS=Terasort/Output
INPUT_HDFS=HiBench/Terasort/Input
OUTPUT_HDFS=HiBench/Terasort/Output
#INPUT_HDFS=dtap://TenantStorage/Terasort/Input-1TB
#OUTPUT_HDFS=dtap://TenantStorage/Terasort/Output

export JAVA_HOME=/usr/java/jdk1.7.0_67-cloudera/
export HADOOP_HOME=/opt/cloudera/parcels/CDH/lib/hadoop
export HADOOP_EXECUTABLE=$HADOOP_HOME/bin/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/
export MAPRED_EXECUTABLE=/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/bin/mapred
export HADOOP_EXAMPLES_JAR=/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar

PARAMS=""
PARAMS="$PARAMS -Dmapreduce.map.output.compress=true"
PARAMS="$PARAMS -Dmapreduce.reduce.shuffle.parallelcopies=36"
PARAMS="$PARAMS -Dmapreduce.input.fileinputformat.split.maxsize=1073741824"
PARAMS="$PARAMS -Ddfs.blocksize=1024M"

#PARAMS="$PARAMS -Dmapreduce.map.memory.mb=3584"
#PARAMS="$PARAMS -Dmapreduce.map.java.opts=-Xmx2688m"
PARAMS="$PARAMS -Dmapreduce.map.memory.mb=2100"
#PARAMS="$PARAMS -Dmapreduce.map.java.opts=-Xmx1300m"

#tuning intermediate storage 
PARAMS="$PARAMS -Dmapreduce.task.io.sort.mb=1300"
PARAMS="$PARAMS -Dmapreduce.task.io.sort.factor=100"
PARAMS="$PARAMS -Dmapreduce.map.sort.spill.percent=0.99"

#PARAMS="$PARAMS -Dmapreduce.reduce.memory.mb=3072"
#PARAMS="$PARAMS -Dmapreduce.reduce.java.opts=-Xmx2600m"
PARAMS="$PARAMS -Dmapreduce.reduce.memory.mb=2000"
#PARAMS="$PARAMS -Dmapreduce.reduce.java.opts=-Xmx2300m"

PARAMS="$PARAMS -Dyarn.app.mapreduce.am.resource.mb=1300"
PARAMS="$PARAMS -Dyarn.app.mapreduce.am.command-opts=-Xmx1200m"

PARAMS="$PARAMS -Dmapreduce.job.heap.memory-mb.ratio=0.90"
PARAMS="$PARAMS -Dmapreduce.job.reduce.slowstart.completedmaps=0.70"
#PARAMS="$PARAMS -Dmapreduce.reduce.shuffle.merge.percent=0.50"
PARAMS="$PARAMS -Dmapreduce.map.speculative=false"
PARAMS="$PARAMS -Dmapreduce.reduce.speculative=false"
#PARAMS="$PARAMS -Dmapreduce.job.reduces=2304"
#PARAMS="$PARAMS -Dmapreduce.job.reduces=612"
PARAMS="$PARAMS -Dmapreduce.job.reduces=800"

PARAMS="$PARAMS -Dmapreduce.shuffle.max.threads=200"
PARAMS="$PARAMS -Dmapreduce.reduce.shuffle.input.buffer.percent=0.9"
PARAMS="$PARAMS -Dmapreduce.reduce.shuffle.merge.percent=0.9"
PARAMS="$PARAMS -Dmapreduce.reduce.merge.inmem.threshold=0"
PARAMS="$PARAMS -Dmapreduce.reduce.input.buffer.percent=0.9"

PARAMS="$PARAMS -Dmapreduce.terasort.partitions.sample=2000000"

echo [`date +"%Y-%m-%d %T"`] ==================== TeraSort ======================
#echo [`date +"%Y-%m-%d %T"`] RUNID=$runid
echo [`date +"%Y-%m-%d %T"`] Input directory: $INPUT_HDFS
SIZE=`$HADOOP_EXECUTABLE fs -du -s $INPUT_HDFS |awk '{print $1}'`
echo [`date +"%Y-%m-%d %T"`] Input data size: $SIZE bytes.
echo [`date +"%Y-%m-%d %T"`] Output directory: $OUTPUT_HDFS
echo [`date +"%Y-%m-%d %T"`] Removing any existing output data...
#su - hdfs -c "$HADOOP_EXECUTABLE fs -rm -r -skipTrash $OUTPUT_HDFS >/dev/null 2>&1"
$HADOOP_EXECUTABLE fs -rm -r -skipTrash $OUTPUT_HDFS >/dev/null 2>&1

echo [`date +"%Y-%m-%d %T"`] Starting TeraSort...

START=$(date +%s)
set -x
#su - hdfs -c "$HADOOP_EXECUTABLE jar $HADOOP_EXAMPLES_JAR terasort $PARAMS $INPUT_HDFS $OUTPUT_HDFS"
#$HADOOP_EXECUTABLE jar $HADOOP_EXAMPLES_JAR terasort $PARAMS $INPUT_HDFS $OUTPUT_HDFS
$HADOOP_EXECUTABLE jar $HADOOP_EXAMPLES_JAR terasort $PARAMS -Dmapreduce.map.java.opts="-Xmx2000m -Xms2000m" -Dmapreduce.reduce.java.opts="-Xmx1850m -Xms1850m" $INPUT_HDFS $OUTPUT_HDFS
set +x
END=$(date +%s)
DURATION=$((END-START))

echo [`date +"%Y-%m-%d %T"`] Run completed.
echo DataSize = $SIZE bytes
echo SortTime = $DURATION seconds
echo Throughput = `echo "scale=2; $SIZE / $DURATION / 1024 / 1024"|bc` MB/sec
echo [`date +"%Y-%m-%d %T"`] ==================== TeraSort ======================
