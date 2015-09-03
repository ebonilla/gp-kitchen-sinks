function [ A, B ] = mteugpUpdateLinearization( model)
%MTEUGPUPDATELINEARIZATION Summary of this function goes here
%   Detailed explanation goes here
% Updates parameters of linearization
N = model.N;
P = model.P;
Q = model.Q;

A = zeros(N,P,Q);
B = zeros(N,P);

MuF = model.Phi*model.M;

switch (model.linearMethod)
    case 'Taylor',
        for n = 1 : N
            f = MuF(n,:);
            [fval, Jn] = egpEvalFwdModel(model.fwdFunc, f);
            A(n,:,:) = Jn;
            B(n,:)   = fval - f*Jn'; 
        end
    case 'Unscented'
    VarF = getVariancesF(Phi, C);  % NxQ matrix of variances
    for n = 1 : N
        [A(n,:,:), B(n,:) ] = ugpGetLinearization(MuF(n,:), VarF(n,:), model.kappa);          
    end
        
    otherwise 
        fprintf('Unknown Linearization method');
end


end


% get the variances var(fnq), q=1, Q
function V = getVariancesF(Phi, C)
% Phi: NxD matrix of features
% C: DxDxQ matrix of Q DxD covariances (on weights)
% V: NxQ vector of variances
N = size(Phi,1);
Q = size(C,3);
V = zeros(N,Q);
Phi2 = Phi.^2;
for q = 1 : Q
    cq = diag(C(:,:,q)); 
    V(:,q) = Phi2*cq;
end
end

