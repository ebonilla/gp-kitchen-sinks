function [Ybar, J] =  ugpGetStats(MuF, fwdFunc, VarF, kappa, N, P, Q)
% Gets stats from UGP necessary for MAP objective
% we compute the jacobian J form the UGP function
% Edwin V. Bonilla (http://ebonilla.github.io/)


Ybar = zeros(N, P);
J    = zeros(N,P,Q);

for n = 1 : N
    fn         = MuF(n,:);
    [~, Jn] = egpEvalFwdModel(fwdFunc, fn, P, 1, 0);
    J(n,:,:)  = Jn;
    Ybar(n,:) = ugpGetStatsSingle(fn, fwdFunc, VarF(n,:), kappa);
end

end
 


function ybar = ugpGetStatsSingle(muF, fwdFunc, varF, kappa)
% We generate N = 2*Q + 1 sigma points, their weights and observations
% This N has nothing to so with the actual number of observtions in 
% our original problem
Q    =  length(muF);
N    =  2*Q + 1;  
X    =  zeros(Q, N);
E    =  diag(sqrt((Q+kappa)*varF));
muF  =  muF'; % Qx1

% Sigma points
X(:,1)       = muF; % x_0
X(:,  2:Q+1) = bsxfun(@plus, muF,  E);
X(:,Q+2:N)   = bsxfun(@minus, muF,  E);

% Weights
u      = zeros(N, 1);
u(1)   = (kappa)/(Q+kappa); % u_0
u(2:N) =  1/(2*(Q+kappa)); 

% make sure I pass row vectors to fwd model function
% assumes fwdFunc returns a matrix of NxP evaluations (P is dim output)
Y  = fwdFunc(X');  % NxP matrix

% stats
ybar    = sum(bsxfun(@times, u, Y),1); % 1xP


end