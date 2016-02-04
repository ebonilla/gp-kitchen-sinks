function model  = mteugpInitSeismic( model, doffsets, voffsets )
%MTEUGPINITSEISMIC Summary of this function goes here
%   Detailed explanation goes here

% Initializing features
sigmaf          = 1;
model.featParam = model.initFeatFunc(sigmaf);
model.Phi       = model.featFunc(model.X, model.Z, model.featParam); 
model.D         = size(model.Phi,2); % actual number of features

% likelihood variances
%model.sigma2y = 0.01*var(model.Y, 0, 1)';
model.sigma2y =  ones(model.P,1);

% hyper-parameters (of prior on w)
%model.sigma2w = 1e8*ones(model.Q,1);  
% THIS IS GOOD
% model.sigma2w = [1e8*ones(model.Q/2,1); 1e8*ones(model.Q/2,1)];  
totalVar      = mean(mean(model.Phi*model.Phi'))';
model.sigma2w =[1e8*ones(model.Q/2,1); 1e8*ones(model.Q/2,1)]/totalVar;

% means, lineariz. and covariances
%model.M = randn(model.D,model.Q);
%model.M  = 0.01*ones(model.D,model.Q);
%model.M = 0.01*randn(model.D,model.Q);
n_layers = model.Q/2;
height0 = bsxfun(@plus, zeros(n_layers, model.N) , doffsets');
vel0    = bsxfun(@plus, zeros(n_layers, model.N) , voffsets');
F       = [height0', vel0'];
jit    = 1e-7*eye(model.D);

model.M = (model.Phi'*model.Phi + jit)\(model.Phi'*F);
%model.M = 0.0001*ones(model.D,model.Q);

% The UGP needs the covariances 
if ( strcmp(model.linearMethod, 'Unscented') )
    C = eye(model.D);
    for q = 1 : model.Q
        model.C(:,:,q) =  C;
    end
end

[model.A, model.B] = mteugpUpdateLinearization(model); % lineariz. parameters
model              = mteugpOptimizeCovariances( model );


fprintf('Initial feature parameter = %.4f\n', exp(model.featParam) );
fprintf('Initial sigma2y = %.4f\n', model.sigma2y );
fprintf('Initial sigma2w = %.4f\n', model.sigma2w);
fprintf('Variational Parameter Optimizer %s\n', model.varConf.optimizer);
fprintf('Hyperparameter Optimizer %s\n', model.hyperConf.optimizer);


% fprintf('Initial Nelbo = %.2f\n', mteugpNelbo( model ) );



end

