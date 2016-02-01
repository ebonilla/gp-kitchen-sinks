#!/bin/bash
#PBS -q short48
#PBS -N mnistArray
#PBS -l walltime=72:00:00 -l nodes=1:ppn=12,mem=8GB,vmem=8GB
#PBS -J 1-4
 
# Use: qsub submit_all_cluster_array_mnist.sh

##### Obtain Parameters from input.txt file using $PBS_ARRAY_INDEX as the line number #####
parameters=`sed -n "${PBS_ARRAY_INDEX} p" input_mnist.txt`
parameterArray=($parameters)
idxMethod=${parameterArray[0]}
d=${parameterArray[1]}
boolSample=${parameterArray[2]}
writeLog=${parameterArray[3]}

##### Execute Program #####
printf "Values used are %d %d %d %d\n" $idxMethod $d $boolSample $writeLog
./run_mteugp_cluster_array_mnist.sh $idxMethod $d $boolSample $writeLog




















