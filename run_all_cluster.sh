#!/bin/bash
# Just running for the first 20 configurations
D=100
writeLog=1
NBENCH=1
NMETHOD=1
NFOLD=1
for ((idxBench=1;idxBench<=$NBENCH;idxBench+=1)); do
    for ((idxMethod=1;idxMethod<=$NMETHOD;idxMethod+=1)); do
	for ((idxFold=1;idxFold<=$NFOLD;idxFold+=1)); do
	    ./run_mteugp_cluster.sh $idxBench $idxMethod $idxFold $D $writeLog
	done
    done
done







