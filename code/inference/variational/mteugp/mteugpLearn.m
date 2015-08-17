function  model  = mteugpLearn( model, optconf )
%MTEUGPLEARN Summary of this function goes here
%   Detailed explanation goes here

Q = model.Q;
D = model.D;

%% Initializing model
model.M            = zeros(D,Q);
[model.A, model.B] = mteugpUpdateLinearization(model); % lineariz. parameters
for q = 1 : Q
    model.C(:,:,q) = updateCovariance(model,q);
end

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
i = 1;
nelbo = - NaN*ones(optconf.maxiter,1);
nelbo(i) = mteugpNelbo( model );
while (i <= optconf.maxiter)
    grad_mq = getGradMq(model, mq, sigma2w, Sigmainv, N, q);
    H      =  getHessMq(model, mq, sigma2w, Sigmainv, N, q); % does not really depend on mq
    L      = chol(H, 'lower');
    dmq    = solve_chol(L',grad_mq);
    mq     = mq  - optconf.alpha*dmq;

    model.M(:,q) = mq; 
    nelbo(i)     = mteugpNelbo( model );

    % TODO: Need to update linearization within Newton or outside?
    
    fprintf('Nelbo(%d) = %.2f \n', i, nelbo(i));    
    i = i + 1;
end

%% After mean converged, update covariance
% TODO: update linearization parameters?
[model.A, model.B] = mteugpUpdateLinearization(model);

Cq = updateCovariance(model,q);


end


%% Cq = updateCovariance(model)
function Cq = updateCovariance(model, q)
N        = model.N;
Sigmainv = diag(model.sigma2y);
sigma2w  = model.sigma2w(q);
mq       = model.M(:,q);

H    = getHessMq(model, mq, sigma2w, Sigmainv, N, q);
L    = chol(H, 'lower');
Cq   = getInverseChol(L);
end


%% getHessMq(model, mq, sigma2w, Sigmainv, N, q)
function H = getHessMq(model, mq, sigma2w, Sigmainv, N, q)
D = model.D;
H =  - sigma2w * eye(D);
for n = 1 : N
    phin = model.Phi(n,:)';
    anq  = model.A(n,:,q)';
    H    = H - phin*anq'*Sigmainv*anq*phin'; 
end

% minimizing negative ebo
H = - H;

end


%% grad_mq = getGradMq(model, mq, sigma2w, Sigmainv, N, q)
function grad_mq = getGradMq(model, mq, sigma2w, Sigmainv, N, q)
grad_mq = - (1/sigma2w)*mq;
for n = 1 : N
    yn       = model.Y(n,:)';
    phin     = model.Phi(n,:)';
    anq      = model.A(n,:,q)';
    bn       = model.B(n,:)';
    grad_mq  =  grad_mq + phin*anq'*Sigmainv*(yn - anq*mq'*phin - bn);                 
end


% minimizing negative ebo
grad_mq = - grad_mq;

end
