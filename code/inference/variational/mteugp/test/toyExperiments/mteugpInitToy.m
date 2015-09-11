function  model  = mteugpInitToy( model )
%MTEUGPINIT Summary of this function goes here
% [ model ] = mteugpInit( model )
%   Initializes all model parameters


% Initializing features
model.featParam = feval(model.initFeatFunc);
model.Phi       = feval(model.featFunc, model.X, model.featParam); 
model.D         = size(model.Phi,2); % actual number of features

% likelihood variances
model.sigma2y = 0.01*var(model.Y, 0, 1)';


% hyper-parameters (of prior on w)
model.sigma2w = ones(model.Q,1); 


% means, lineariz. and covariances
%model.M            = randn(model.D,model.Q);
model.M            = 0.01*randn(model.D,model.Q);


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

% fprintf('Initial Nelbo = %.2f\n', mteugpNelbo( model ) );



end

 
function  model  = mteugpInit2( model )
%MTEUGPINIT Summary of this function goes here
% [ model ] = mteugpInit( model )
%   Initializes all model parameters


% Initializing features
model.featParam = feval(model.initFeatFunc);
model.Phi       = feval(model.featFunc, model.X, model.featParam); 
model.D         = size(model.Phi,2); % actual number of features

% likelihood variances
model.sigma2y = 0.01*var(model.Y, 0, 1)';


% hyper-parameters (of prior on w)
model.sigma2w = ones(model.Q,1); 

% linearization parameters
model.A  = ones(model.N, model.P,model.Q);
model.B  = zeros(model.N,model.P);

%model.M     = zeros(model.D,model.Q);
%model       = mteugpOptimizeMeans( model );

% [model.A, model.B] = mteugpUpdateLinearization(model); % lineariz. parameters
% model              = mteugpOptimizeCovariances( model );


fprintf('Initial feature parameter = %.4f\n', exp(model.featParam) );
fprintf('Initial sigma2y = %.4f\n', model.sigma2y );
fprintf('Initial sigma2w = %.4f\n', model.sigma2w);

% fprintf('Initial Nelbo = %.2f\n', mteugpNelbo( model ) );



end
