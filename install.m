clear all; clc;
% Edwin V. Bonilla (http://ebonilla.github.io/)

%% mexing solve_chol.c
cd lib/gpml;
try
    mex -lmwlapack -lmwblas solve_chol.c;
catch
    disp('Unable to mex solve_chol.c, using slower solve_chol.m ');
end
cd ../../;

%% Checking that nlopt is installed
try
    nloptvar = NLOPT_LN_BOBYQA;
catch
    fprintf('Warning: It seems nlopt has not been installed.\n');
    fprintf('Make sure you install it and add it to Matlab path.\n');
end
