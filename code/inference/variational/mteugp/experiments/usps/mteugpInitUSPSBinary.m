function model  = mteugpInitUSPSBinary( model )
%MTEUGPINITUSPS Summary of this function goes here
%   Detailed explanation goes here

exitCode = 0;

% We try to init from a previous run
if ( model.initFromFile )
    [model, exitCode]  = mteugpInitFromFile( model );
end

if(~exitCode) % Default initialization
    model.featParam = feval(model.initFeatFunc);    
    model.sigma2y   = 0.01*ones(model.P,1);   % likelihood variances
    model.sigma2w   = 1*ones(model.Q,1);  % hyper-parameters (of prior on w)
    model.Phi       = feval(model.featFunc, model.X, model.Z, model.featParam); 
    model.D         = size(model.Phi,2); % actual number of features    
    model.M         = 0.01*randn(model.D,model.Q);
    %model.M         = zeros(model.D,model.Q);
    
    % The UGP needs the covariances 
    if ( strcmp(model.linearMethod, 'Unscented') )
        C = eye(model.D);
        for q = 1 : model.Q
            model.C(:,:,q) =  C;
        end
    end
    
    % Updates linearization
    [model.A, model.B] = mteugpUpdateLinearization(model); % lineariz. parameters
    model              = mteugpOptimizeCovariances( model );

end

    

fprintf('Initial feature parameter = %.4f\n', exp(model.featParam) );
fprintf('Initial sigma2y = %.4f\n', model.sigma2y );
fprintf('Initial sigma2w = %.4f\n', model.sigma2w);

% fprintf('Initial Nelbo = %.2f\n', mteugpNelbo( model ) );

% Save initial model on target directory
strFile = strrep(model.resultsFname, '.mat', '_0.mat');
save(strFile, 'model');

end

 
 
