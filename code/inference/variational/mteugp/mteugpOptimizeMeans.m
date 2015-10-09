function [ model ] = mteugpOptimizeMeans( model )
%MTEUPOPTIMIZEMEANS Summary of this function goes here
%   Detailed explanation goes here
% Optmize means and linearization parameters

if ( isfield(model, 'useNewton') ) 
    if (model.useNewton == 1) 
        model = optimizeMeansNewton(model);
        return;
    end
end

fprintf('Optimizing Means Starting...\n');
model  = mteugpOptimizeMeansMap( model);
fprintf('Optimizing Means Done\n');

end   


function model = optimizeMeansNewton(model)
% optimization of means
for q = 1 : model.Q
        model  = optimizeSingleM(model, q, model.varConf);  
end

end


function model = optimizeSingleM(model, q, optconf)
% We need to check the objcetive function
N            = model.N;
diagSigmaInv = 1./ model.sigma2y;
mq           = model.M(:,q);
sigma2w      = model.sigma2w(q);

%% Newton iterations
i = 1;
tol = inf;
mqOld = model.M(:,q);
while ( (i <= optconf.iter)  && (tol > optconf.ftol))    
    grad_mq      =  mteugpGetGradMq(model, mq, sigma2w, diagSigmaInv, N, q);
    H            =  mteugpGetHessMq(model, mq, sigma2w, diagSigmaInv, N, q); % does not really depend on mq
    L            = getCholSafe(H);
    dmq          = solve_chol(L',grad_mq);
    [mq, A, B, difNelbo, diverge] = lineSearch(model, mq, dmq, q, optconf.alpha, 20);
    if (diverge)
        return;
    end
    % Updating means in linearization parameters
    model.M(:,q) = mq; 
    model.A      = A;
    model.B      = B;
    
    
    %tol  = norm(mq - mqOld);
    %tol = max(abs((mq - mqOld)./mq));
    tol  = abs(difNelbo);
    
    fprintf('Newton nelbo(%d)=%.4f\n',i, mteugpNelbo(model));
    mqOld = mq;
    i = i + 1;
end


end

function [mq, A, B, difNelbo, diverge] = lineSearch(model, mq, dmq, q, alpha, iter)
% return 0 if it could not find a step
step = 1;
nelboOld = mteugpNelbo(model);
difNelbo = Inf;
i = 0;
diverge = 0;
% Finds the largest step that reduces the nelbo
while ( (difNelbo > 0) && (i <=iter) )
    step               = step*alpha;
    model.M(:,q)       = mq  - step*dmq;
    [model.A, model.B] = mteugpUpdateLinearization(model);     % Updates linerization    
    nelbo              = mteugpNelbo(model);
    difNelbo           = nelbo - nelboOld;
    i                   = i + 1;
end
if (difNelbo > 0)
    diverge = 1;
    A   = [];
    B   = [];
else
    mq = model.M(:,q);
    A = model.A;
    B = model.B;
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
diagSigmaInv = 1./ model.sigma2y;
mq           = model.M(:,q);
sigma2w      = model.sigma2w(q);

%% Newton iterations
i = 1;
tol = inf;
mqOld = model.M(:,q);
while ( (i <= optconf.iter) && (tol > optconf.xtol) )    
    grad_mq      =  mteugpGetGradMq(model, mq, sigma2w, diagSigmaInv, N, q);
    H            =  mteugpGetHessMq(model, mq, sigma2w, diagSigmaInv, N, q); % does not really depend on mq
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
 % pause;

end

%% Optimizes for a single q
% it updates M and the linearization parameters A, B
function model = optimizeSingleM1(model, q, optconf)
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
    fprintf('Nelbo(%d) = %.2f \n', i, nelbo(i));    
    tol = abs(nelbo(i) - nelbo(i-1));
    
    % Updates linerization
    [model.A, model.B] = mteugpUpdateLinearization(model);
end
pause;

end


