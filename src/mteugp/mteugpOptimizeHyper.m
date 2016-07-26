function model  = mteugpOptimizeHyper(model )
%MTEUGPOPTIMIZE Optimizes negative evidence lower bound wrt
%hyper-parameters
% INPUT:
%   - model: model structured
% OUTPUT:
%   - model: Modifed model with optimal hyper-parameters (and means)
% Edwin V. Bonilla (http://ebonilla.github.io/)

global bestNelbo;

bestNelbo = min(model.nelbo(model.nelbo~=0));
global best_M; % to share with mteugpNelboHyper;
best_M = model.M;

if (model.hyperConf.verbose)
    fprintf('Optimizing Hyper starting \n')
end

theta    = mteugpWrapHyper(model);
optConf  = model.hyperConf;
lb       = mteugpGetHyperLB( model  );
ub       = mteugpGetHyperUB( model  );
theta    = mteugpOptimize(@mteugpNelboHyper, theta, optConf, lb, ub, 0, model );

model  = mteugpUnwrapHyper( model, theta );

% assigns best mean found during optimization of hyper
model.M  = best_M;
 
 
 if (model.hyperConf.verbose)
    fprintf('Optimizing hyper done \n');
 end

end

  