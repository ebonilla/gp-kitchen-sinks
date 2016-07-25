clear all; clc;
cd lib/gpml;
try
    mex -lmwlapack -lmwblas solve_chol.c;
catch
    disp('Unable to mex solve_chol.c, using slower solve_chol.m ');
end

cd ../../;
