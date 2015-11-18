function model  = mteugpOptimizeHyperSimplified(model )
%MTEUGPOPTIMIZE  Optimize Hyper for simplefied nelbo using analytical
%gradients
%   wrapper for differenr optimization algorithms for hyperparameters
% theta = [featureParam; likelihoodParam; PriorParam]
%       = [featureParam; theta_y; theta_w]
%
theta  = mteugpWrapHyperSimplified(model);

optConf = model.hyperConf;
switch optConf.optimizer
    case 'minFunc',
        % numDiff = 0: use user gradients, 1: fwd-diff, 2: centra-diff
        opt = struct('Display', 'full', 'Method', 'lbfgs', ...
                'MaxIter', optConf.iter, 'MaxFunEvals', optConf.eval, ...
                'progTol', optConf.ftol, ...
                'DerivativeCheck','off', 'numDiff', 2); 

        % Using minFunc
        [theta, nelboFeat, exitFlag]  = minFunc(@mteugpNelboHyperSimplified, theta, opt, model); 
    
    case 'minimize',
        theta = minimize(theta, @mteugpNelboHyperSimplified, optConf.eval, model);
    
    case 'nlopt', % Using nlopt
        opt.verbose        = optConf.verbose;
        opt.algorithm     = NLOPT_LD_LBFGS;
        opt.min_objective  = @(xx) mteugpNelboHyperSimplified(xx, model);        
        opt.maxeval        = optConf.eval;
        opt.ftol_rel       = optConf.ftol; % relative tolerance in f
        opt.xtol_rel       = optConf.xtol;
        
        
        % setting lower and upper bounds
        thetaLB          = mteugpGetHyperLB( model  );
        thetaUB          = mteugpGetHyperUB( model  );
        opt.lower_bounds = thetaLB;
        opt.upper_bounds = thetaUB;        
        [theta, fminval, retcode] = nlopt_optimize(opt, theta);
    
end

 model  = mteugpUnwrapHyperSimplified( model, theta );


end

function [nelbo, grad] = mteugpNelboHyperSimplified(theta, model)
model =  mteugpUnwrapHyperSimplified(model, theta);

nelbo  = mteugpNelboSimplified( model );

if (nargout == 1) 
    return;
end

% if gradients are required
% I AM HERE 

end


function theta = mteugpWrapHyperSimplified(model)
 theta   = model.featParam;
 theta  =  [theta; mteugpWrapSigma2y(model.sigma2y)];
 theta   = [theta; mteugpWrapSigma2w(model.sigma2w)];

end

function  model =  mteugpUnwrapHyperSimplified(model, theta)
L          = length(theta);
P          = model.P; % Number of tasks
Q          = model.Q; % Number of latent functions

nFeatParam = L - P - Q; % Number of feature parameters
theta_f    = theta(1:nFeatParam);
theta_y    = theta(nFeatParam + 1 : nFeatParam + P);
theta_w    = theta(nFeatParam + P + 1 : L); % should be Q-dimensional

model.sigma2y = mteugpUnrwapSigma2y(theta_y);
model.sigma2w = mteugpUnrwapSigma2w(theta_w);
model         = mteugpUpdateFeatures(model, theta_f);


end


















