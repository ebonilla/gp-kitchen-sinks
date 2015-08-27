function  model  = mteugpOptimizeFeatures( model)
%MTEUGPOPTIMIZEFEATURES Summary of this function goes here
%   Detailed explanation goes here

theta   = model.featParam;         % optimization of feature parameters
optConf = model.optConf;

switch optConf.optimizer
    case 'minFunc',
        % numDiff = 0: use user gradients, 1: fwd-diff, 2: centra-diff
        optFeat = struct('Display', 'full', 'Method', 'lbfgs', 'MaxIter', optConf.featIter,...
        'MaxFunEvals', optConf.featEval, 'DerivativeCheck','off', 'numDiff', 2); 

        % Using minFunc
        [model.featParam, nelboFeat, exitFlag]  = minFunc(@mteugNelboFeat, theta, optFeat, model); 
    
    case 'minimize',
        model.featParam = minimize(theta, @mteugNelboFeat, optConf.featEval, model);
    
    case 'nlopt', % Using nlopt
        opt.verbose       = 1;
        %opt.algorithm     = NLOPT_LD_LBFGS;
        opt.algorithm      = NLOPT_LN_BOBYQA; % numerical opt.
        opt.min_objective = @(xx) mteugNelboFeat(xx, model);
        [model.featParam, fminval, retcode] = nlopt_optimize(opt, theta);
    
end

% update features
model.Phi = feval(model.featFunc, model.X, model.featParam); 
fprintf('Nelbo after updating feat param. = %.2f\n', mteugpNelbo( model ) );

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