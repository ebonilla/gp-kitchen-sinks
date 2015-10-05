#!/bin/bash
# prints a file with the all the multiple inputs to run 
boolSample=0
writeLog=0
NMETHOD=2
DLIST='
100
200
500
1000
'

for d in $DLIST; do
  for ((idxMethod=1;idxMethod<=$NMETHOD;idxMethod+=1)); do
      printf "%d %d %d %d\n" $idxMethod $d $boolSample $writeLog
  done
done




















