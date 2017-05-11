#!/bin/bash

# This script is used to run TeraSort workload from the ResourceManager node of a YARN cluster, either physical or virtual.
# This script should have no dependency on anything other than the Haddop environment.

INPUT_HDFS=benchmarks
HOME_DIR=/root/TPCX-BB_V1.1

echo [`date +"%Y-%m-%d %T"`] ==================== TPCx-BB ======================
echo [`date +"%Y-%m-%d %T"`] TPCx-BB Run started.

START=$(date +%s)
set -x
cd $HOME_DIR/bin
./bigBench runBenchmark
set +x
END=$(date +%s)
DURATION=$((END-START))

echo [`date +"%Y-%m-%d %T"`] Run completed.


echo [`date +"%Y-%m-%d %T"`] ==================== TPCx-BB ======================
