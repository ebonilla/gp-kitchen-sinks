#!/bin/bash
source ~/.bashrc

FILENAME='code/inference/variational/mteugp/experiments/mnistBinary/mteugpTestMNISTBinary.m'
P1='./data'
P2='./code/inference/variational/mteugp'
P3='./code/inference/variational/utils'
P4='./code/inference/features'
P5='./external'
TARGETDIR='standalone/MNISTBinary'




# Deleting previous files
#rm $1     
#rm $1_main.c                
#rm run_$1.sh
#rm $1.ctf  
#rm $1_mcc_component_data.c
#rm $1.prj
#rm -r $1_mcr
#rm -r $1.app


/share/apps/matlab/2014b/bin/mcc -R -nojvm -m  $FILENAME -a $P1 -a $P2 -a $P3 -a $P4 -a $P5 -d $TARGETDIR -o mteugpMNISTBinary -v 

# ../scripts/*.m ../utils/*.m ../softmax-class/*.m ../external/gpml/*.m ../external/Netlab/*.m   
# mteugpTestToydata.m -d standalone/toyData -o mteugp -v




