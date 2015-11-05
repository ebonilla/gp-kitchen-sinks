function [Gval, J, H] =  egpGetStats(MuF, fwdFunc, jacobian, diaghess, N, P, Q)
Gval = zeros(N,P);
J    = zeros(N,P,Q);
if (nargout == 2) % hessian not required
    for n = 1 : N   
        f = MuF(n,:);
        [gvaln, Jn] = egpEvalFwdModel(fwdFunc, f, P, jacobian, diaghess);
        J(n,:,:)  = Jn;
        Gval(n,:) = gvaln;    
    end
    return;
end

H    = zeros(N,P,Q);
for n = 1 : N
    f = MuF(n,:);
    [gvaln, Jn, Hn] = egpEvalFwdModel(fwdFunc, f, P, jacobian, diaghess);
    J(n,:,:)  = Jn;
    H(n,:,:)  = Hn;
    Gval(n,:) = gvaln; 
end        

end

