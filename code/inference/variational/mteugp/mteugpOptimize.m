function [theta, fval, exitCode] =  ...
                mteugpOptimize(fobj, theta0, optConf, lb, ub, boolGrad, model )
%MTEUGPOPTIMIZE Summary of this function goes here
%   Detailed explanation goes here
% wrapper for other optimizers


switch optConf.optimizer
    case 'minFunc',
        % numDiff = 0: use user gradients, 1: fwd-diff, 2: centra-diff
        opt = struct('Display', 'full', 'Method', 'lbfgs', ...
                'MaxIter', optConf.iter, 'MaxFunEvals', optConf.eval, ...
                'progTol', optConf.ftol, ...
                'DerivativeCheck','off', 'numDiff', 2); 
            
        % Using minFunc
        [theta, fval, exitCode]  = minFunc(fobj, theta0, opt, model); 
    
    case 'minimize',
        theta = minimize(theta0, fobj, optConf.eval, model);
    
    case 'nlopt', % Using nlopt
        opt.verbose        = optConf.verbose;
        if (boolGrad)
            opt.algorithm     = NLOPT_LD_LBFGS;
        else
            opt.algorithm      = NLOPT_LN_BOBYQA; % numerical opt.
        end
        opt.min_objective  = @(xx) fobj(xx, model);
        opt.maxeval        = optConf.eval;
        opt.ftol_rel       = optConf.ftol; % relative tolerance in f
        opt.xtol_rel       = optConf.xtol;      
        if ( ~isempty(lb) )
            opt.lower_bounds   = lb;
        end
        if ( ~isempty(ub) )
            opt.upper_bounds   = ub;        
        end
        
        [theta, fval, exitCode] = nlopt_optimize(opt, theta0);
        
    case 'fminunc'  % Matlab's optimizer
        options = optimoptions('fminunc');
        if (boolGrad) % gradient provided
            options.Algorithm = 'quasi-newton'; 
            options.GradObj   = 'on'; 
        else
            options.Algorithm = 'quasi-newton';
        end
        options.MaxIter = optConf.iter;
        %options.Display = 'iter';
        options.Display = 'off';
        ptrFunc = @(xx) fobj(xx, model);
        [theta, fval, exitCode]   = fminunc(ptrFunc, theta0, options);
    otherwise 
        ME = MException('UnknownOptimizer:NotDefined', ...
             ['Optimizer ', optConf.optimizer, ' unknown']);
        throw(ME);
    
end

end



 
