function [Gval, J] =  egpGetStats(MuF, fwdFunc, jacobian, N, P, Q)
J    = zeros(N,P,Q);
Gval = zeros(N,P);
for n = 1 : N
    f = MuF(n,:);
    [gvaln, Jn] = egpEvalFwdModel(fwdFunc, f, jacobian);
    J(n,:,:)  = Jn;
    Gval(n,:) = gvaln; 
end        

