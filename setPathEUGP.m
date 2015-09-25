% sets path for inference algorithms, mainly variational stuff

%% order may matter here
addpath(genpath('code/inference/variational/mteugp'));
addpath(genpath('code/inference/variational/utils'));
addpath(genpath('code/inference/features'));
addpath('data');



%path(path(), genpath('~/Dropbox/Matlab/utils')); % sq_dist from here, plots, etc
%path(path(), genpath('~/Dropbox/Matlab/gpml-matlab-v3.6-2015-07-07')); % covfuncs
%path(path(), genpath('~/Dropbox/Matlab/DERIVESTsuite')); % jacobians
%addpath(genpath('~/Dropbox/Matlab/minFunc_2012'));
%addpath(genpath('/Users/ebonilla/Documents/software/nlopt')); %'nlopt'
% All these paths are now in external dir
addpath(genpath('external'));
