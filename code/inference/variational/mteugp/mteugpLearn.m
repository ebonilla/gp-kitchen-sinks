function  model  = mteugpLearn( model, optconf )
%MTEUGPLEARN Summary of this function goes here
%   Detailed explanation goes here

Q = model.Q;
D = model.D;

%% Initializing model
model.M = zeros(D,Q);

%% Optimization 
for q = 1 : Q
    [model.M(:,q), model.C(:,:,q)]  = optimizeSingleM(model, q, optconf);
end

end




%% Optimizes for a single q
function [mq, Cq] = optimizeSingleM(model, q, optconf)
% optconf: Optimization configuration
% optconf.maxiter
% optconf.tol
% optconf.alpha: learning rate

N        = model.N;
D        = model.D;
sigma2y  = model.sigma2y;
Sigmainv = diag(sigma2y);
mq       = model.M(:,q);
sigma2w  = model.sigma2w(q);

%% Newton iterations
i = 0;
while (i < optconf.maxiter)
    grad_mq = getGradMq(model, mq, sigma2w, Sigmainv, N, q);
    H      = getHessMq(model, mq, sigma2w, Sigmainv, N, q); % does not really depend on mq
    L      = chol(H, 'lower');
    dmq    = solve_chol(L',grad_mq);
    mq     = mq - optconf.alpha*dmq;
    i = i + 1;
    
    % TODO: Need to update linearization within Newton or outside?
end

%% After mean converged, update covariance
% TODO: update linearization parameters?
[model.A, model.B] = mteugpUdateLinearization(model);


H    = - getHessMq(model, mq, sigma2w, Sigmainv, N, q);
L    = chol(H, 'lower');
Cq   = getInverseChol(L);


end



%% getHessMq(model, mq, sigma2w, Sigmainv, N, q)
function H = getHessMq(model, mq, sigma2w, Sigmainv, N, q)
H =  - sigma2w * eye(D);
for n = 1 : N
    phin = model.Phi(n,:)';
    anq  = model.A(n,:,q)';
    H    = H - phin*anq'*Sigmainv*anq*phin'; 
end

end


%% grad_mq = getGradMq(model, mq, sigma2w, Sigmainv, N, q)
function grad_mq = getGradMq(model, mq, sigma2w, Sigmainv, N, q)
grad_mq = zeros(size(mq));
for n = 1 : N
    yn       = model.Y(n,:)';
    phin     = model.Phi(n,:)';
    anq      = model.A(n,:,q)';
    bn       = model.B(n,:)';
    grad_mq  =  grad_mq + phin*anq'*Sigmainv*(yn - anq*mq'*phin - bn) ...
                - (1/sigma2w)*mq;
end

end
