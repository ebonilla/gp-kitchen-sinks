function [ A, B ] = mteugpUpdateLinearization( model)
%MTEUGPUPDATELINEARIZATION Summary of this function goes here
%   Detailed explanation goes here
% Updates parameters of linearization
N = model.N;
P = model.P;
Q = model.Q;

A = zeros(N,P,Q);
B = zeros(N,P);

F = model.Phi*model.M;

switch (model.linearMethod)
    case 'Taylor',
        for n = 1 : N
            f = F(n,:);
            [fval, Jn] = egpEvalFwdModel(model.fwdFunc, f);
            A(n,:,:) = Jn;
            B(n,:)   = fval - f*Jn'; 
        end
    otherwise 
        fprintf('Unknown Linearization method');
end


end
