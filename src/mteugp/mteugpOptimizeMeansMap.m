function  [model, fval, exitCode]  = mteugpOptimizeMeansMap(model)
%MTEUGPOPTIMIZEMEANSMAP Optimizes the mean using the MAP objective
% INPUT:
%   - model: model structure
% OUTPUT:
%   - model: modified model structured with optimized means
%   - fval: Final value of objective function
%   - exitCode: Termination flag (optimizer dependent)
% Edwin V. Bonilla (http://ebonilla.github.io/)

if (model.varConf.verbose)
    fprintf('Optimizing Means Starting...\n');
end
optConf = model.varConf;
theta0  = model.M(:);
[theta,fval, exitCode]   = mteugpOptimize( @mapObjective, theta0, optConf, [], [], 1, model );
model.M =  reshape(theta, model.D, model.Q); 

% Updates linearization parametes
[model.A, model.B] = mteugpUpdateLinearization(model); 

if (model.varConf.verbose)
    fprintf('Optimizing Means Done\n');
end

end
 

function [lmap, grad] = mapObjective(theta, model)
M             = reshape(theta, model.D, model.Q);
diagSigmayinv  = 1./model.sigma2y; % Px1 
diagSigmawinv = 1./model.sigma2w;  % Qx1  
gradM  = zeros(size(M));
 
switch (model.linearMethod)
    case 'Taylor',
        MuF = model.Phi*M;
        [Gval, J] =  egpGetStats(MuF, model.fwdFunc, model.jacobian, model.diaghess, model.N, model.P, model.Q);
        Ytilde    = model.Y - Gval;
        Ys        = bsxfun(@times, Ytilde, diagSigmayinv'); % NxP
        lmap      = sum(sum(Ys.*Ytilde));
        
        M_off      = M - model.priorMean;
        Ms        = bsxfun(@times, M_off, diagSigmawinv'); % DxQ
        lmap      = 0.5*(lmap +  sum(sum(Ms.*M_off)));
        
        for q = 1 : model.Q
            Jq         = J(:,:,q); % N x P
           gradM(:,q)  = - model.Phi'*sum(Jq.*Ys, 2); % Dx1
        end
        gradM = gradM  + Ms;
        
    case 'Unscented',
        % we still need the Jacobian for the gradient    
        MuF       = model.Phi*M;
        VarF      = mteugpGetVariancesF(model.Phi, model.C); 
        [Gval, J] = ugpGetStats(MuF, model.fwdFunc, VarF, model.kappa, model.N, model.P, model.Q);

        Ytilde = model.Y - Gval;
        Ys     = bsxfun(@times, Ytilde, diagSigmayinv'); % NxP
        lmap   = sum(sum(Ys.*Ytilde));
        
         M_off      = M - model.priorMean;
         Ms    = bsxfun(@times, M_off, diagSigmawinv'); % DxQ
        lmap   = 0.5*(lmap +  sum(sum(Ms.*M_off)));
        
        for q = 1 : model.Q
            Jq         = J(:,:,q); % N x P
           gradM(:,q)  = - model.Phi'*sum(Jq.*Ys, 2); % Dx1
        end
        gradM = gradM  + Ms;
    
    otherwise,
        ME = MException('VerifyInputMethod:InvalidLinearization', ...
                        ['Invalid Linearization Method ', model.linearMethod]);
        throw(ME);
end
grad = gradM(:);

end



 
























  