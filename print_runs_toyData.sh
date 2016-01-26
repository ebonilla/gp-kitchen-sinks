#!/bin/bash
# prints a file with the all the multiple inputs to run 
D=100
writeLog=1
NBENCH=5
NMETHOD=2
NFOLD=5
DLIST='
10
20
50
100
'

for d in $DLIST; do
   for ((idxBench=1;idxBench<=$NBENCH;idxBench+=1)); do
       for ((idxMethod=1;idxMethod<=$NMETHOD;idxMethod+=1)); do
   	   for ((idxFold=1;idxFold<=$NFOLD;idxFold+=1)); do
	       printf "%d %d %d %d %d\n" $idxBench $idxMethod $idxFold $d $writeLog
	   done
       done
   done
done
















