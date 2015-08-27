function  model  = mteugpOptimizeFeatures( model)
%MTEUGPOPTIMIZEFEATURES Summary of this function goes here
%   Detailed explanation goes here

theta   = model.featParam;         % optimization of feature parameters
optConf = model.featConf;

switch optConf.optimizer
    case 'minFunc',
        % numDiff = 0: use user gradients, 1: fwd-diff, 2: centra-diff
        optFeat = struct('Display', 'full', 'Method', 'lbfgs', 'MaxIter', optConf.iter,...
        'MaxFunEvals', optConf.eval, 'DerivativeCheck','off', 'numDiff', 2); 

        % Using minFunc
        [model.featParam, nelboFeat, exitFlag]  = minFunc(@mteugNelboFeat, theta, optFeat, model); 
    
    case 'minimize',
        model.featParam = minimize(theta, @mteugNelboFeat, optConf.eval, model);
    
    case 'nlopt', % Using nlopt
        opt.verbose        = optConf.verbose;
        %opt.algorithm     = NLOPT_LD_LBFGS;
        opt.algorithm      = NLOPT_LN_BOBYQA; % numerical opt.
        opt.min_objective  = @(xx) mteugNelboFeat(xx, model);
        
        opt.maxeval        = optConf.eval;
        opt.ftol_abs       = optConf.tol;
        
        [model.featParam, fminval, retcode] = nlopt_optimize(opt, theta);
    
end

% update features
model.Phi = feval(model.featFunc, model.X, model.featParam); 

end



%% function testGradients
 function testGradientsFeat(model)
% test gradients wrt feat parameters
% Do not use anonymys function here as model is modified inside functions
% fobj = @(xx) mteugNelboFeat(xx, model);
theta = model.featParam;
[delta, g, g2] = derivativeCheck(@mteugNelboFeat, theta, 1, 2, model);
for i = 1 : 10
    theta = log(rand(size(model.featParam)));
    [delta, g, g2] = derivativeCheck(@mteugNelboFeat, theta, 1, 2, model);
end
end