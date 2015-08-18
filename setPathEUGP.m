% sets path for inference algorithms, mainly variational stuff

%% order may matter here
addpath(genpath('code/inference/variational/mteugp'));
addpath(genpath('code/inference/variational/utils'));
addpath(genpath('code/inference/features'));


path(path(), genpath('~/Dropbox/Matlab/utils')); % sq_dist from here, plots, etc
path(path(), genpath('~/Dropbox/Matlab/gpml-matlab-v3.6-2015-07-07')); % covfuncs
path(path(), genpath('~/Dropbox/Matlab/DERIVESTsuite')); % jacobians

%addpath(genpath('/Users/edwinbonilla/Dropbox/Matlab/minFunc_2012'));
%addpath(genpath('/Users/edwinbonilla/Software/nlopt')); %'nlopt'

