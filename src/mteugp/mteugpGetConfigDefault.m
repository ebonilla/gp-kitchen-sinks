function  model  = mteugpGetConfigDefault( X, Y, fwdFunc, linearMethod, D )
%MTEUGPGETCONFIGTOY Get configuration for toy experiment
d = size(X,2);

%% feature function
model.Z            = randn(D,d);
model.featFunc     =  @getRandomRBF;
model.initFeatFunc = @initRandomRBF;

%% set up model
model.Q            = 1;         % # latent functions
model.P            = size(Y,2); % # Outputs
model.N            = size(X,1); % # datapoints
model.D            = D;         % # Feature dimensionality
model.Y            = Y;
model.X            = X;

%% Linearization parameters
model.linearMethod = linearMethod;  % 'Taylor' or 'Unscented'
model.fwdFunc      = fwdFunc;       % Forward model
model.jacobian     = 0;             % 1/0 if jacobian is provided
model.diaghess     = 1;             % [irrelevant]
model.kappa        = 1/2;           % parameter of Unscented linearization

%% Prior
featParam       = model.initFeatFunc(1);
Phi             = model.featFunc(model.X, model.Z, featParam); 
D               = size(Phi,2);
model.priorMean = zeros(D,model.Q);


%% prediction settings
model.nSamples    = 1000; % Number of samples for approximating g* wehen using mc
model.predMethod  = 'mc'; % {'mc', 'Taylor'} % for prediction of g* 

%% global optimization configuration
optConf.iter     = 50;    % maximum global iterations
optConf.ftol     = 1e-5;
model.globalConf = optConf;


%% variational parameter optimization configuration
optConf.optimizer = 'nlopt'; % for hyper-parameters
model.useNewton   = 1;       % use own Newton optimizer for var param
optConf.iter      = 100;     % maximum iterations on variational parameters
optConf.eval      = 200;
optConf.ftol      = 1e-5;
optConf.xtol      = 1e-8; % tolerance for Newton iterations
optConf.alpha     = 0.9;  % learning rate for Newton iterations
optConf.verbose   =  0;
model.varConf     = optConf;

 
%% Hyperparameter optimization configuration
optConf.optimizer = 'nlopt'; % for hyper-parameters
optConf.iter      = 100;  % maximum iterations for hyper parametes (minfunc parameter)
optConf.eval      = 200;  % Maxium evals for hyper paramters func (minFunc parameter)
optConf.ftol      = 1e-5; % Tolerance in f
optConf.xtol      = 1e-8; % Tolerance in x
optConf.verbose   = 0; % 0: none, 1: full
model.hyperConf   = optConf;

%% initialization Function
model.initFunc    = @mteugpInitDefault;

%% Results directory
model.resultsFname = [];

end



 
