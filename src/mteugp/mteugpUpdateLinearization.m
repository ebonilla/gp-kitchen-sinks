function [ A, B ] = mteugpUpdateLinearization( model)
%MTEUGPUPDATELINEARIZATION Summary of this function goes here
%   Detailed explanation goes here
% Updates parameters of linearization
% N = model.N;
% Edwin V. Bonilla (http://ebonilla.github.io/)


N = size(model.Phi, 1); % more general to handle test data (phi = phi_*)
P = model.P;
Q = model.Q;

A = zeros(N,P,Q);
B = zeros(N,P);

MuF = model.Phi*model.M;

switch (model.linearMethod)
    case 'Taylor',
        for n = 1 : N
            f = MuF(n,:);
            [fval, Jn] = egpEvalFwdModel(model.fwdFunc, f, model.jacobian, model.diaghess);
            A(n,:,:) = Jn;
            B(n,:)   = fval - f*Jn'; 
        end
    case 'Unscented'
    VarF = mteugpGetVariancesF(model.Phi, model.C);  % NxQ matrix of variances
    for n = 1 : N
        [A(n,:,:), B(n,:) ] = ugpGetLinearization(model.fwdFunc,MuF(n,:), VarF(n,:), model.kappa);          
    end
        
    otherwise 
        fprintf('Unknown Linearization method');
end


end




