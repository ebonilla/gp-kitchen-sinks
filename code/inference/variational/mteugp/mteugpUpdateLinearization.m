function [ A, B ] = mteugpUpdateLinearization( model)
%MTEUGPUPDATELINEARIZATION Summary of this function goes here
%   Detailed explanation goes here
% Updates parameters of linearization
A = zeros(N,P,Q);
B = zeros(N,P);


switch (model.linearMethod)
    case 'Taylor',
        egpEvalFwdModel(model.fwdFunc, f );
    otherwise 
        fprintf('Unknown Linearization method');
end


end
