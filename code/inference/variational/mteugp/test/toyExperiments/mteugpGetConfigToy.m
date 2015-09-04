function  model  = mteugpGetConfigToy( X, Y, benchmark, linearMethod )
%MTEUGPGETCONFIGTOY Get configuration for toy experiment
d = size(X,2);
D = 100; % Number of features to use

%% feature function
Z            = randn(D,d);
featFunc     =  @(xx, ss) getRandomRBF(xx, Z, ss); % function of (x, vargargin)
initFeatFunc = @initRandomRBF;

%% set up model
model.Q            = 1; % latent functions
model.P            = size(Y,2); % Outputs
model.N            = size(X,1);
model.D            = D;
model.Y            = Y;
model.X            = X;

model.featFunc     = featFunc;  % feature function
model.initFeatFunc = initFeatFunc; % initializes Parameters of feature function

model.linearMethod = linearMethod; % 'Taylor' or 'Unscented'
model.fwdFunc      = @(ff) mteugpToyFwdModel(ff,benchmark ) ;  
model.jacobian     = 1;
model.kappa        = 1/2; % parameter of Unscented linearization

model.nSamples     = 1000; % Number of samples for approximating predictive dist.

% global optimization configuration
optConf.iter     = 50;    % maximum global iterations
optConf.tol      = 1e-3;
model.globalConf = optConf;

% variational parameter optimization configuration
optConf.iter    = 50;  % maximum iterations on variational parameters
optConf.tol     = 1e-3; % tolerance for Newton iterations
optConf.alpha   = 0.5;  % learning rate for Newton iterations
model.varConf   = optConf;
 
% Hyperparameter optimization configuration
optConf.iter      = 100;  % maximum iterations for hyper parametes (minfunc parameter)
optConf.eval      = 50;  % Maxium evals for hyper paramters func (minFunc parameter)
optConf.optimizer = 'nlopt'; % for hyper-parameters
optConf.tol       = 1e-3; % Tolerance for hyper optimization 
optConf.verbose   = 1; % 0: none, 1: full
model.hyperConf   = optConf;


end


