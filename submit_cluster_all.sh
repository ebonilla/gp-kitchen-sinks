#!/bin/bash
D=100
writeLog=1
NBENCH=5
NMETHOD=2
NFOLD=5
for ((idxBench=1;idxBench<=$NBENCH;idxBench+=1)); do
    for ((idxMethod=1;idxMethod<=$NMETHOD;idxMethod+=1)); do
	for ((idxFold=1;idxFold<=$NFOLD;idxFold+=1)); do
	    qsub -q short48 -N 'toyData-'$idxBench'-'$idxMethod'-'$idxFold  -l walltime=01:00:00 -l nodes=1:ppn=48,mem=4GB,vmem=4GB -v ARG1=$idxBench,ARG2=$idxMethod,ARG3=$idxFold,ARG4=$D,ARG5=$writeLog run_mteugp_cluster.sh
	done
    done
done












