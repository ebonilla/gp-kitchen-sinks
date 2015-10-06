function  model  = mteugpGetConfigMNISTBinary( X, Y, linearMethod, D )
%MTEUGPGETCONFIGTOY Get configuration for USPS experiment
d = size(X,2);
%D = 100; % Number of features to use

%% feature function
model.Z            = randn(D,d);
model.featFunc     = @getRandomRBF; % function of (x, Z, vargargin)
model.initFeatFunc = @initRandomRBF;

%% set up model
model.Q            = 1; % latent functions
model.P            = size(Y,2); % Outputs
model.N            = size(X,1);
model.D            = D;
model.Y            = Y;
model.X            = X;

model.linearMethod = linearMethod; % 'Taylor' or 'Unscented'
model.fwdFunc      = @mteugpFwdLogistic;  
model.jacobian     = 1;  % 1/0 if jacobian is provided
model.kappa        = 1/2; % parameter of Unscented linearization

model.nSamples     = 1000; % Number of samples for approximating predictive dist.

% global optimization configuration
optConf.iter     = 100;    % maximum global iterations
optConf.ftol     = 1e-3;
model.globalConf = optConf;

% variational parameter optimization configuration
optConf.iter    = 200;  % maximum iterations on variational parameters
optConf.ftol   = 1e-3;
% optConf.xtol   = 1e-8; % tolerance for Newton iterations
optConf.alpha   = 0.9;  % learning rate for Newton iterations
model.varConf   = optConf;
 
% Hyperparameter optimization configuration
optConf.iter      = [];  % maximum iterations for hyper parametes (minfunc parameter)
optConf.eval      = 50;  % Maxium evals for hyper paramters func (minFunc parameter)
optConf.optimizer = 'nlopt'; % for hyper-parameters
optConf.ftol       = 1e-3; % Tolerance in f
optConf.xtol       = 1e-3; % Tolerance in x
optConf.verbose   = 1; % 0: none, 1: full
model.hyperConf   = optConf;

% lower bounds on hyperparameters
model.hyperLB.sigma2y   = 1e-7*ones(model.P,1);

% initialization Function
model.initFunc    = @mteugpInitMNISTBinary;

%
model.initFromFile = 0;

end


 


  
