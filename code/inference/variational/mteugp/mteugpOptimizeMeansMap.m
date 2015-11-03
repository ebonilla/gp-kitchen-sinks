function  model  = mteugpOptimizeMeansMap(model)
%MTEUGPOPTIMIZEMEANSMAP Uses the MAP objective
%   Detailed explanation goes here


%for testing purposes only % Using minFunc
% opt = struct('Display', 'full', 'Method', 'lbfgs', ...
%                'MaxIter', 10, 'MaxFunEvals', 100, ...
%                'progTol', 1e-3, ...
%                'DerivativeCheck','on', 'numDiff', 0); 
% theta = model.M(:);
% [theta, nelboFeat, exitFlag]  = minFunc(@mapObjective, theta, opt, model); 

optConf             = model.varConf;
opt.verbose         = optConf.verbose;
opt.algorithm       = NLOPT_LD_LBFGS; % numerical opt.
opt.min_objective   = @(xx) mapObjective(xx, model);
opt.maxeval         = optConf.eval;
opt.ftol_rel        = optConf.ftol; % relative tolerance in f
opt.xtol_rel        = optConf.xtol;

theta0 = model.M(:);
[theta, fminval, retcode] = nlopt_optimize(opt, theta0);
model.M =  reshape(theta, model.D, model.Q); 

% Updates linearization parametes
[model.A, model.B] = mteugpUpdateLinearization(model); 

end
 

function [lmap, grad] = mapObjective(theta, model)
M             = reshape(theta, model.D, model.Q);
diagSigmayinv  = 1./model.sigma2y;
diagSigmawinv = 1./model.sigma2w;   
gradM  = zeros(size(M));

switch (model.linearMethod)
    case 'Taylor',
        MuF = model.Phi*M;
        [Gval, J] =  egpGetStats(MuF, model.fwdFunc, model.jacobian, model.N, model.P, model.Q);
        Ytilde    = model.Y - Gval;
        Ys        = bsxfun(@times, Ytilde, diagSigmayinv); % NxP
        lmap      = sum(sum(Ys.*Ytilde));
         Ms        = bsxfun(@times, M, diagSigmawinv); % DxQ
        lmap      = 0.5*(lmap +  sum(sum(Ms.*M)));
        
        for q = 1 : model.Q
            Jq         = J(:,:,q); % N x P
           gradM(:,q)  = - model.Phi'*sum(Jq.*Ys, 2); % Dx1
        end
        gradM = gradM  + Ms;
        
    case 'Unscented'
        

end
grad = gradM(:);

end






  