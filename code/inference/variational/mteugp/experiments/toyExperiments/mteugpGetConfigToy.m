function  model  = mteugpGetConfigToy( X, Y, benchmark, linearMethod, D )
%MTEUGPGETCONFIGTOY Get configuration for toy experiment
d = size(X,2);
%D = 100; % Number of features to use

%% feature function
model.Z            = randn(D,d);
%featFunc           =  @(xx, ss) getRandomRBF(xx, Z, ss); % function of (x, vargargin)
featFunc           =  @getRandomRBF;
initFeatFunc       = @initRandomRBF;

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
model.fwdFunc      = @(ff) mteugpFwdModelToy(ff,benchmark ) ;  
model.jacobian     = 1;  % 1/0 if jacobian is provided
model.diaghess     = 1; 
model.kappa        = 1/2; % parameter of Unscented linearization

% prediction settings
model.nSamples     = 1000; % Number of samples for approximating predictive dist.
model.predMethod   = 'mc'; % {'mc', 'Taylor'}

% global optimization configuration
optConf.iter     = 50;    % maximum global iterations
optConf.ftol     = 1e-5;
model.globalConf = optConf;

% variational parameter optimization configuration
optConf.iter    = 200;  % maximum iterations on variational parameters
optConf.eval    = 100;
optConf.ftol   = 1e-5;
optConf.xtol   = 1e-8; % tolerance for Newton iterations
optConf.alpha   = 0.9;  % learning rate for Newton iterations
optConf.verbose = 0;
optConf.optimizer = 'nlopt'; % for hyper-parameters
model.varConf   = optConf;

% transforms on hyperparameters for unconstrained optimization
model.featTransform     = 'linear'; % Note this is control by feature function
model.lambdayTransform  = 'exp'; % Precisions are exponential of parameter
model.lambdawTransform  = 'exp'; % precisions are exponential of parameter

% Hyperparameter optimization configuration
optConf.iter      = [];  % maximum iterations for hyper parametes (minfunc parameter)
optConf.eval      = 50;  % Maxium evals for hyper paramters func (minFunc parameter)
optConf.ftol       = 1e-5; % Tolerance in f
optConf.xtol       = 1e-8; % Tolerance in x
optConf.verbose   = 0; % 0: none, 1: full
optConf.optimizer = 'nlopt'; % for hyper-parameters
model.hyperConf   = optConf;

% initialization Function
model.initFunc    = @mteugpInitToy;

end


 
  