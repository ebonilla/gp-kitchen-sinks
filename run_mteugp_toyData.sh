#!/bin/bash


#1 idxBench
#2 idxMethod
#3 idxFold
#4 D
#5 writeLog

#export MCR_INHIBIT_CTF_LOCK=1
#export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/applications/matlab/r2009b/runtime/glnxa64"
#./learn_models $1 $2 $3 $4 $5 $6

./standalone/toyData/run_mteugpToyData.sh /Applications/MATLAB/MATLAB_Compiler_Runtime/v84 $1 $2 $3 $4 $5








