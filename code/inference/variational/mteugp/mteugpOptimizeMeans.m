function [ model ] = mteugpOptimizeMeans( model )
%MTEUPOPTIMIZEMEANS Summary of this function goes here
%   Detailed explanation goes here
% Optmize means and linearization parameters

% optimization of means
for q = 1 : model.Q
        model  = optimizeSingleM2(model, q, model.varConf);  
end

end




function model = optimizeSingleM2(model, q, optconf)
% same as  optimizeSingleM but measure convergence on parameter space 
% rather in Nelbo --> avoids computation of the Nelbo
% optconf: Optimization configuration
% optconf.maxiter
% optconf.tol
% optconf.alpha: learning rate

N            = model.N;
diagSigmainv = 1./ model.sigma2y;
mq           = model.M(:,q);
sigma2w      = model.sigma2w(q);

%% Newton iterations
i = 1;
tol = inf;
mqOld = model.M(:,q);
while ( (i <= optconf.iter) && (tol > optconf.xtol) )    
    grad_mq      =  mteugpGetGradMq(model, mq, sigma2w, diagSigmainv, N, q);
    H            =  mteugpGetHessMq(model, mq, sigma2w, diagSigmainv, N, q); % does not really depend on mq
    L            = getCholSafe(H);
    dmq          = solve_chol(L',grad_mq);
    mq           = mq  - optconf.alpha*dmq;
    model.M(:,q) = mq; 
    [model.A, model.B] = mteugpUpdateLinearization(model);     % Updates linerization    
    tol   = norm(mq - mqOld);
    %tol = max(abs((mq - mqOld)./mq));
    
    fprintf('Newton nelbo(%d)=%.4f\n',i, mteugpNelbo(model));
    mqOld = mq;
    i = i + 1;
end
 pause;

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
while ( (i <= optconf.iter) && (tol > optconf.ftol) )    
    grad_mq = mteugpGetGradMq(model, mq, sigma2w, Sigmainv, N, q);
    H      =  mteugpGetHessMq(model, mq, sigma2w, Sigmainv, N, q); % does not really depend on mq
    L      = getCholSafe(H);
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


