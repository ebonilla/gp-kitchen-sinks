function model  = mteugpInitUSPS( model )
%MTEUGPINITUSPS Summary of this function goes here
%   Detailed explanation goes here



% Initializing features
model.featParam = feval(model.initFeatFunc);
model.Phi       = feval(model.featFunc, model.X, model.featParam); 
model.D         = size(model.Phi,2); % actual number of features

% likelihood variances
model.sigma2y = 0.001*ones(model.P,1);


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



 
