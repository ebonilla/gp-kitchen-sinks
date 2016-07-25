function  model  = mteugpGetConfigToy( X, Y, benchmark, linearMethod, D )
%MTEUGPGETCONFIGTOY Get configuration for toy experiment
d = size(X,2);
%D = 100; % Number of features to use

%% feature function
model.Z            = randn(D,d);
model.featFunc     =  @getRandomRBF;
model.initFeatFunc = @initRandomRBF;

%% set up model
model.Q            = 1; % latent functions
model.P            = size(Y,2); % Outputs
model.N            = size(X,1);
model.D            = D;
model.Y            = Y;
model.X            = X;

model.linearMethod = linearMethod; % 'Taylor' or 'Unscented'
model.fwdFunc      = @(ff) mteugpFwdModelToy(ff,benchmark ) ;  
model.jacobian     = 1;  % 1/0 if jacobian is provided
model.diaghess     = 1; 
model.kappa        = 1/2; % parameter of Unscented linearization

% prediction settings
model.nSamples     = 1000; % Number of samples for approximating g* wehen using mc
model.predMethod   = 'mc'; % {'mc', 'Taylor'} % for prediction of g* 

% global optimization configuration
optConf.iter     = 50;    % maximum global iterations
optConf.ftol     = 1e-5;
model.globalConf = optConf;

% variational parameter optimization configuration
optConf.optimizer = 'nlopt'; % for hyper-parameters
model.useNewton   = 1;       % use own Newton optimizer for var param
optConf.iter      = 100;     % maximum iterations on variational parameters
optConf.eval      = 200;
optConf.ftol      = 1e-5;
optConf.xtol      = 1e-8; % tolerance for Newton iterations
optConf.alpha     = 0.9;  % learning rate for Newton iterations
optConf.verbose   =  0;
model.varConf     = optConf;

% Hyperparameter optimization configuration
optConf.optimizer = 'nlopt'; % for hyper-parameters
optConf.iter      = 100;  % maximum iterations for hyper parametes (minfunc parameter)
optConf.eval      = 200;  % Maxium evals for hyper paramters func (minFunc parameter)
optConf.ftol      = 1e-5; % Tolerance in f
optConf.xtol      = 1e-8; % Tolerance in x
optConf.verbose   = 0; % 0: none, 1: full
model.hyperConf   = optConf;

% transforms on hyperparameters for unconstrained optimization
model.featTransform     = 'linear'; % Note this is control by feature function
model.lambdayTransform  = 'exp'; % Precisions are exponential of parameter
model.lambdawTransform  = 'exp'; % precisions are exponential of parameter


% initialization Function
model.initFunc    = @mteugpInitToy;

end


 
  