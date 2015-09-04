function  V  = mteugpGetVariancesF( Phi, C )
%MTEUGPGETVARIANCESF get the variances var(fnq), q=1, Q
%   Detailed explanation goes here
% Phi: NxD matrix of features
% C: DxDxQ matrix of Q DxD covariances (on weights)
% V: NxQ vector of variances
N = size(Phi,1);
Q = size(C,3);
V = zeros(N,Q);
for q = 1 : Q
    Cq     = C(:,:,q);
    V(:,q) =  diagProd(Phi*Cq, Phi');
end
end

 