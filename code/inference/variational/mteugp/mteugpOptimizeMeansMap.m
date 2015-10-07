function  model  = mteugpOptimizeMeansMap( model)
%MTEUGPOPTIMIZEMEANSMAP Uses the MAP objective
%   Detailed explanation goes here


%for testing purposes only % Using minFunc
opt = struct('Display', 'full', 'Method', 'lbfgs', ...
               'MaxIter', 10, 'MaxFunEvals', 10, ...
               'progTol', 1e-3, ...
               'DerivativeCheck','on', 'numDiff', 0); 
theta = model.M(:);
[theta, nelboFeat, exitFlag]  = minFunc(@mapObjective, theta, opt, model); 
    
        

end


function [lmap, grad] = mapObjective(theta, model)
M             = reshape(theta, model.D, model.Q);
diagSigmayinv  = 1./model.sigma2y;
diagSigmawinv = 1./model.sigma2w;   
gradM  = zeros(size(M));

switch (model.linearMethod)
    case 'Taylor',
        MuF = model.Phi*model.M;
        [Gval, J] =  getStatsEGP(MuF, model.fwdFunc, model.jacobian, model.N, model.P, model.Q);
        Ytilde    = model.Y - Gval;
        Ys        = bsxfun(@times, Ytilde, diagSigmayinv); % NxP
        lmap      = sum(sum(Ys.*Ytilde));
         Ms        = bsxfun(@times, M, diagSigmawinv); % DxQ
        lmap      = 0.5*(lmap +  sum(sum(Ms.*M)));
        
        for q = 1 : model.Q
            Jq         = J(:,:,q); % N x P
           gradM(:,q)  = model.Phi'*sum(Jq.*Ys, 2); % Dx1
        end
        gradM = gradM  + Ms;
        
    case 'Unscented'

end
grad = gradM(:);

end



function [Gval, J] =  getStatsEGP(MuF, fwdFunc, jacobian, N, P, Q)
J    = zeros(N,P,Q);
Gval = zeros(N,P);
for n = 1 : N
    f = MuF(n,:);
    [gvaln, Jn] = egpEvalFwdModel(fwdFunc, f, jacobian);
    J(n,:,:)  = Jn;
    Gval(n,:) = gvaln; 
end        


end
