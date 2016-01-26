#!/bin/bash
#PBS -q short48
#PBS -N toyDataArray
#PBS -l walltime=04:00:00 -l nodes=1:ppn=12,mem=8GB,vmem=8GB
#PBS -J 1-150

# Use: qsub submit_all_cluster_array_toyData.sh

##### Obtain Parameters from inputToyData.txt file using $PBS_ARRAY_INDEX as the line number #####
parameters=`sed -n "${PBS_ARRAY_INDEX} p" inputToyData.txt`
parameterArray=($parameters)
idxBench=${parameterArray[0]}
idxMethod=${parameterArray[1]}
idxFold=${parameterArray[2]}
d=${parameterArray[3]}
writeLog=${parameterArray[4]}

##### Execute Program #####
printf "Values used are %d %d %d %d %d\n" $idxBench $idxMethod $idxFold $d $writeLog
./run_mteugp_cluster_array.sh $idxBench $idxMethod $idxFold $d $writeLog

















