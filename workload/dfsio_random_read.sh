#!/bin/bash

nrFiles=535
fileSize=`expr 1000000000000 / $nrFiles / 1024`

cmd=" -read -random -skipSize 0 -nrFiles $nrFiles -size ${fileSize}KB"

source dfsio_base.sh
prepare
run $cmd


