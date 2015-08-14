function [ A, B ] = mteugpUpdateLinearization( model)
%MTEUGPUPDATELINEARIZATION Summary of this function goes here
%   Detailed explanation goes here
% Updates parameters of linearization
A = zeros(N,P,Q);
B = zeros(N,P);

F = model.Phi*model.M;

switch (model.linearMethod)
    case 'Taylor',
        for n = 1 : N
            f = F(n,:);
            [fval, Jn] = egpEvalFwdModel(model.fwdFunc, f);
            A(n,:,:) = Jn;
        end
    otherwise 
        fprintf('Unknown Linearization method');
end


end
