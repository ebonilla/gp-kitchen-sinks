function [m S] = learn_q_gpsvi(y, Knm, Lmm, Kmminv, diagKtilde, betaval, cf)
% Learns q(u | m, S) via stochastic variational inference
% i.e. stochastic optimization of m,S using the natural gradients
% Here we receive all data and parameters and implement the randomization
% inside
% TODO: split the data before and distribute computation
% cf: optimization configuration
%
% theta1 = (S^-1) m
% theta2 = -(1/2)*S^-1 --> S = - 2* inv(theta2)
%
% Lmm, diagKtilde not used but kept for consistency temporarily

[N M] = size(Knm);

if (~isempty(cf.Sinv0) )
    Sinv = cf.Sinv0;
else
    var_y = var(y);
    Sinv = 0.01*(1/var_y)*eye(M);
end

if (~isempty(cf.m0))
    m  = cf.m0;
else
    idx = randperm(N);
    m   =  y(idx(1:M));
end

theta1_old = Sinv*m;
theta2_old = -0.5*Sinv;

lrate = cf.lrate;

%% I think this should be a permutation instead
%IDX = randi(N, cf.nbatch,cf.maxiter);

for i = 1 : cf.maxiter 
    
    %% Selects subset of training data at random
    % Need to do this outside the loop as here is "inefficient"
    %idx       = IDX(:,i);
    idx       = randperm(N, cf.nbatch)';
    
    
    Kmnval    = Knm(idx,:)';
    A         = Kmminv*Kmnval;
    Lambdaval = betaval*(A*A') + Kmminv;
    yval      = y(idx);
    
    theta2 = theta2_old + lrate*(-0.5*Lambdaval - theta2_old);
    theta1 = theta1_old + lrate*(betaval*A*yval - theta1_old);
   
    theta1_old = theta1;
    theta2_old = theta2;
    
    %% DELETE THIS: Used only for test purposes: evaluates bound on all data
    [VV DD]     = eig(theta2);
    invTheta2   =  invEig(VV, DD); 
    S           = - (0.5) * invTheta2;
    m           = S*theta1;
    logL        = l3bound(y, Knm, Lmm, Kmminv, diagKtilde, betaval, m, S, cf.jitter);
    semilogy(i,logL, 'rx'); hold on; drawnow;
    fprintf('logL(%d)=%.4f\n',i, logL);
    
end


[VV DD]     = eig(theta2);
invTheta2   =  VV*diag(1./diag(DD))*VV';
S           = - (0.5) * invTheta2;
m           = S*theta1;


return;

