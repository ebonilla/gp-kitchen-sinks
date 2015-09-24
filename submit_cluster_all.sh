#!/bin/bash
#!/bin/bash
# Just running for the first 20 configurations
D=100
writeLog=1
NBENCH=5
NMETHOD=2
NFOLD=5
for ((idxBench=1;idxBench<=$NBENCH;idxBench+=1)); do
    for ((idxMethod=1;idxMethod<=$NMETHOD;idxMethod+=1)); do
	for ((idxFold=1;idxFold<=$NFOLD;idxFold+=1)); do
	    #PBS -N test
	    #PBS -l walltime=02:00:00
	    #PBS -l nodes=1:ppn=1,mem=4GB,vmem=4GB
	    qsub ./run_mteugp.sh $idxBench $idxMethod $idxFold $D $writeLog
	done
    done
done




