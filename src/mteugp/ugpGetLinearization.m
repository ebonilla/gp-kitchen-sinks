function [ An, bn ] = ugpGetLinearization(fwdFunc, muF, varF, kappa)
%UGPGETLINEARIZATION Summary of this function goes here
%   Get linearization using the unscented transform
% MuF: 1xQ vector of means 
% VarF: 1xQ vector of variances
% kappa: Parameter of the unscented transform 

% We generate N = 2*Q + 1 sigma points, their weights and observations
% This N has nothing to so with the actual number of observtions in 
% our original problem
% Edwin V. Bonilla (http://ebonilla.github.io/)


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
Ytilde  = bsxfun(@minus, Y, ybar); % NxP 
Ytilde  = bsxfun(@times, u, Ytilde);  % NxP
Xtilde  = bsxfun(@minus, X, muF); % QxN
Sigmayx = (Xtilde*Ytilde)'; % PxQ 
Sigmaxx = diag(1./varF);

% linearization parameters
An  = Sigmayx*Sigmaxx; % PxQ. TODO: Do this more efficiently as Sigmaxxi is diag
bn  = ybar - (An*muF)'; % 1xP 



end

