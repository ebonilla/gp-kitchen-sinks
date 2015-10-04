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
	    #qsub -cwd -l h_rt=6:00:00 ./run_models.sh 'logreg' $lambda $wsize $fold $fold $NITER
	    #qsub -cwd -l h_rt=6:00:00 ./run_models.sh 'crf' $lambda $wsize $fold $fold $NITER
	    #echo qsub -cwd -l h_rt=6:00:00 ./run_models.sh 'crf' $lambda $wsize $fold $fold $NITER
	    #./run_mteugp.sh $idxBench $idxMethod $idxFold $D $writeLog
	done
    done
done





