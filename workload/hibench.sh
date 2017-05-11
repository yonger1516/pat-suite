#!/bin/bash
#export INPUT_HDFS=HiBench/Terasort/Input-1TB
#export INPUT_HDFS=HiBench/Terasort/Input-500GB
#export INPUT_HDFS=HiBench/Terasort/Input-100GB
#export OUTPUT_HDFS=HiBench/Terasort/Output

export JAVA_HOME=/usr/java/jdk1.7.0_67-cloudera/
export HADOOP_HOME=/opt/cloudera/parcels/CDH/lib/hadoop
export HADOOP_EXECUTABLE=$HADOOP_HOME/bin/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/
export MAPRED_EXECUTABLE=/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/bin/mapred
export HADOOP_EXAMPLES_JAR=/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar

HIBENCH_BASE=/root/spark/HiBench
rm -rf /tmp/result/
mkdir /tmp/result/

export PARAMS
export NUTCH_OPTS=$PARAMS
export NUTCH_HEAPSIZE=2000

echo [`date +"%Y-%m-%d %T"`] ==================== HiBench  ======================
cd $HIBENCH_BASE/../

START=$(date +%s)
set -x

./test_all.sh > /tmp/stdout 1>>/tmp/stdout 2>>/tmp/stdout
#./test_all.sh.bm > /tmp/stdout 1>>/tmp/stdout 2>>/tmp/stdout

set +x
END=$(date +%s)
DURATION=$((END-START))

cp HiBench/report/hibench.report /tmp/result/
cp /tmp/stdout /tmp/result/
tar czf /tmp/result.tgz /tmp/result/
