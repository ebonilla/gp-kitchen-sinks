function theta  = mteugpOptimizeHyper(model )
%MTEUGPOPTIMIZE Summary of this function goes here
%   wrapper for differenr optimization algorithms for hyperparameters
% theta = [featureParam; likelihoodParam; PriorParam]
%       = [featureParam; sigma2y; sigma2w]
%
% featureParam: used directly by model.featFunc
% sigma2y = exp(theta_y): P-dimensional vector
% Although  sigma2w is a D-dimensional here we consider an isotropic 
% parameterization sigma2w = exp(theta_w)*ones(D,1)

theta = model.featParam; % feture Parameters are taken care of by feature function
theta = [theta; log(model.sigma2y)];     
theta = [theta; model.sigma2w(1)]; % ISOTROPIC PRIOR ASSUMPTION IN OPTIMIZATION!

optConf = model.featConf;
switch optConf.optimizer
    case 'minFunc',
        % numDiff = 0: use user gradients, 1: fwd-diff, 2: centra-diff
        optFeat = struct('Display', 'full', 'Method', 'lbfgs', 'MaxIter', optConf.iter,...
        'MaxFunEvals', optConf.eval, 'DerivativeCheck','off', 'numDiff', 2); 

        % Using minFunc
        [theta, nelboFeat, exitFlag]  = minFunc(@mteugpNelboHyper, theta, optFeat, model); 
    
    case 'minimize',
        model.featParam = minimize(theta, @mteugpNelboHyper, optConf.eval, model);
    
    case 'nlopt', % Using nlopt
        opt.verbose        = optConf.verbose;
        %opt.algorithm     = NLOPT_LD_LBFGS;
        opt.algorithm      = NLOPT_LN_BOBYQA; % numerical opt.
        opt.min_objective  = @(xx) mteugpNelboHyper(xx, model);
        
        opt.maxeval        = optConf.eval;
        opt.ftol_abs       = optConf.tol;
        
        [model.featParam, fminval, retcode] = nlopt_optimize(opt, theta);
    
end

end

