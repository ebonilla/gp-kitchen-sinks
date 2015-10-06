function model  = mteugpOptimizeHyper(model )
%MTEUGPOPTIMIZE Summary of this function goes here
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
        [theta, nelboFeat, exitFlag]  = minFunc(@mteugpNelboHyper, theta, opt, model); 
    
    case 'minimize',
        theta = minimize(theta, @mteugpNelboHyper, optConf.eval, model);
    
    case 'nlopt', % Using nlopt
        opt.verbose        = optConf.verbose;
        %opt.algorithm     = NLOPT_LD_LBFGS;
        opt.algorithm      = NLOPT_LN_BOBYQA; % numerical opt.
        opt.min_objective  = @(xx) mteugpNelboHyper(xx, model);
        
        opt.maxeval        = optConf.eval;
        opt.ftol_rel       = optConf.ftol; % relative tolerance in f
        opt.xtol_rel       = optConf.xtol;
        
        
        % setting lower bounds
        thetaLB          = mteugpGetHyperLB( model  );
        opt.lower_bounds = thetaLB; 
        [theta, fminval, retcode] = nlopt_optimize(opt, theta);
    
end

 model  = mteugpUnwrapHyper( model, theta );


end

 