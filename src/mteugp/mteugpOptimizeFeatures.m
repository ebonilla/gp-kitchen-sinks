function  model  = mteugpOptimizeFeatures( model)
%MTEUGPOPTIMIZEFEATURES Summary of this function goes here
%   Detailed explanation goes here
% Edwin V. Bonilla (http://ebonilla.github.io/)

global bestNelbo;
bestNelbo = min(model.nelbo(model.nelbo~=0));
global best_M; % to share with mteugpNelboHyper;
best_M = model.M;


theta   = model.featParam;         % optimization of feature parameters
optConf = model.hyperConf;
model.featParam    = mteugpOptimize(@mteugNelboFeat, theta, optConf, [], [], 0, model );
 

% update features
model.Phi = model.featFunc(model.X, model.Z, model.featParam); 

% assigns best mean found during optimization of hyper
model.M  = best_M;

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