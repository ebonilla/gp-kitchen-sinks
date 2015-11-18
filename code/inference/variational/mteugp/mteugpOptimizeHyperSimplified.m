function model  = mteugpOptimizeHyperSimplified(model )
%MTEUGPOPTIMIZE  Optimize Hyper for simplefied nelbo using analytical
%gradients
%   wrapper for differenr optimization algorithms for hyperparameters
% theta = [featureParam; likelihoodParam; PriorParam]
%       = [featureParam; theta_y; theta_w]
%
theta  = mteugpWrapHyper(model);

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
        opt.min_objective  = @(xx) mteugpNelboHyperSimplified(xx, model);s        
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

 model  = mteugpUnwrapHyper( model, theta );


end

 