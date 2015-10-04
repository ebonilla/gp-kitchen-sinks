function  model  = mteugpGetConfigMNIST( X, Y, linearMethod, D )
%MTEUGPGETCONFIGTOY Get configuration for USPS experiment
d = size(X,2);
%D = 100; % Number of features to use

%% feature function
Z            = randn(D,d);
featFunc     =  @(xx, ss) getRandomRBF(xx, Z, ss); % function of (x, vargargin)
initFeatFunc = @initRandomRBF;

%% set up model
model.Q            = size(Y,2); % latent functions
model.P            = size(Y,2); % Outputs
model.N            = size(X,1);
model.D            = D;
model.Y            = Y;
model.X            = X;

model.featFunc     = featFunc;  % feature function
model.initFeatFunc = initFeatFunc; % initializes Parameters of feature function

model.linearMethod = linearMethod; % 'Taylor' or 'Unscented'
model.fwdFunc      = @mteugpFwdSoftmax;  
model.jacobian     = 1;  % 1/0 if jacobian is provided
model.kappa        = 1/2; % parameter of Unscented linearization

model.nSamples     = 1000; % Number of samples for approximating predictive dist.

% global optimization configuration
optConf.iter     = 5;    % maximum global iterations
optConf.ftol     = 1e-5;
model.globalConf = optConf;

% variational parameter optimization configuration
optConf.iter    = 200;  % maximum iterations on variational parameters
optConf.ftol   = 1e-5;
% optConf.xtol   = 1e-8; % tolerance for Newton iterations
optConf.alpha   = 0.9;  % learning rate for Newton iterations
model.varConf   = optConf;
 
% Hyperparameter optimization configuration
optConf.iter      = [];  % maximum iterations for hyper parametes (minfunc parameter)
optConf.eval      = 50;  % Maxium evals for hyper paramters func (minFunc parameter)
optConf.optimizer = 'nlopt'; % for hyper-parameters
optConf.ftol       = 1e-5; % Tolerance in f
optConf.xtol       = 1e-8; % Tolerance in x
optConf.verbose   = 1; % 0: none, 1: full
model.hyperConf   = optConf;

% initialization Function
model.initFunc    = @mteugpInitMNIST;

end


 
  