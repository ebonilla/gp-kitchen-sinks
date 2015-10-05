#!/bin/bash
#source ~/.bashrc

echo 'debug-'$1'-'$2'-'$3'-'$4
MCRROOT=/home/z3503119/research/projects/bayes-inv-var/standalone/MCR/v84
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:.:${MCRROOT}/runtime/glnxa64
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/bin/glnxa64 
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/os/glnxa64
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/opengl/lib/glnxa64
export LD_LIBRARY_PATH
echo LD_LIBRARY_PATH is ${LD_LIBRARY_PATH}


/home/z3503119/research/projects/bayes-inv-var/standalone/MNIST/mteugpMNIST $1 $2 $3 $4














