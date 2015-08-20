function  model  = mteugpLearn( model, optconf )
%MTEUGPLEARN Summary of this function goes here
%   Detailed explanation goes here

%% initializes feature parameters
model.featParam = feval(model.initFeatFunc);

model.Phi   = feval(model.featFunc, model.X, model.featParam); 
model.D     = size(model.Phi,2); % actual number of features
Q = model.Q;
D = model.D;

%% Initializing model
model.M            = randn(D,Q);
[model.A, model.B] = mteugpUpdateLinearization(model); % lineariz. parameters
for q = 1 : Q
    model.C(:,:,q) = updateCovariance(model,q);
end



% test gradients
% testGradientsFeat(model);
% pause;

% Structure for minFunc 
optFeat = struct('Display', 'final', 'Method', 'lbfgs', 'MaxIter', optconf.featIter,...
    'MaxFunEvals', optconf.featEval, 'DerivativeCheck','off'); 

for i = 1 : optconf.globalIter
    % optimization of means
    for q = 1 : Q
        model  = optimizeSingleM(model, q, optconf);  
    end
   
   % update covariances using optimal mean
    for q = 1 : Q
        model.C(:,:,q) = updateCovariance(model,q);
    end
    fprintf('Nelbo after updating covariances = %.2f\n', mteugpNelbo( model ) );
   
    % optimization of feature parameters
    theta             = model.featParam;
    [model.featParam, nelboFeat, exitFlag]  = minFunc(@mteugNelboFeat, theta, optFeat, model); 
    fprintf('Nelbo after updating feat param. = %.2f\n', mteugpNelbo( model ) );

   
   % optimization of linear parameters
   % [model.A, model.B] = mteugpUpdateLinearization(model);

end




end


%% function testGradients
 function testGradientsFeat(model)
% test gradients wrt feat parameters
% Do not use anonymys function here as model is modified inside functions
% fobj = @(xx) mteugNelboFeat(xx, model);
for i = 1 : 10
    theta = rand(size(model.featParam));
    [delta, g, g2] = derivativeCheck(@mteugNelboFeat, theta, 1, 2, model);
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
Sigmainv = getSigmaInv(sigma2y);
mq       = model.M(:,q);
sigma2w  = model.sigma2w(q);

%% Newton iterations
i = 1;
nelbo    = - NaN*ones(optconf.varIter,1);
nelbo(i) = mteugpNelbo( model );
fprintf('Nelbo(%d) = %.2f \n', i, nelbo(i));    
tol = inf;
while ( (i <= optconf.varIter) && (tol > optconf.tol) )    
    grad_mq = getGradMq(model, mq, sigma2w, Sigmainv, N, q);
    H      =  getHessMq(model, mq, sigma2w, Sigmainv, N, q); % does not really depend on mq
    L      = chol(H, 'lower');
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
 
end


%% function getSigmaInv
function Sigmainv = getSigmaInv(sigma2y)
Sigmainv = diag(1./sigma2y);
end


%% Cq = updateCovariance(model)
function Cq = updateCovariance(model, q)
N        = model.N;
sigma2y  = model.sigma2y;
Sigmainv = getSigmaInv(sigma2y);
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
