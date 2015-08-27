function [ model ] = mteugpOptimizeMeans( model )
%MTEUPOPTIMIZEMEANS Summary of this function goes here
%   Detailed explanation goes here
% Optmize means and linearization parameters

% optimization of means
for q = 1 : model.Q
        model  = optimizeSingleM(model, q, model.varConf);  
end

end

%% Optimizes for a single q
% it updates M and the linearization parameters A, B
function model = optimizeSingleM(model, q, optconf)
% optconf: Optimization configuration
% optconf.maxiter
% optconf.tol
% optconf.alpha: learning rate

N        = model.N;
sigma2y  = model.sigma2y;
Sigmainv = mteugpGetSigmaInv(sigma2y);
mq       = model.M(:,q);
sigma2w  = model.sigma2w(q);

%% Newton iterations
i = 1;
nelbo    = - NaN*ones(optconf.iter,1);
nelbo(i) = mteugpNelbo( model );
%fprintf('Nelbo(%d) = %.2f \n', i, nelbo(i));    
tol = inf;
while ( (i <= optconf.iter) && (tol > optconf.tol) )    
    grad_mq = getGradMq(model, mq, sigma2w, Sigmainv, N, q);
    H      =  mteugpGetHessMq(model, mq, sigma2w, Sigmainv, N, q); % does not really depend on mq
    L      = chol(H, 'lower');
    dmq    = solve_chol(L',grad_mq);
    mq     = mq  - optconf.alpha*dmq;

    model.M(:,q) = mq; 

    % TODO: Need to update linearization within Newton or outside?
    
    i = i + 1;
    nelbo(i)     = mteugpNelbo( model );
    % fprintf('Nelbo(%d) = %.2f \n', i, nelbo(i));    
    tol = abs(nelbo(i) - nelbo(i-1));
    
    % Updates linerization
    [model.A, model.B] = mteugpUpdateLinearization(model);
end
 

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
