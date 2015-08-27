function [ nelbo, grad ] = mteugNelboFeat( theta, model)
%MTEUGNELBOFEAT Summary of this function goes here
%   Detailed explanation goes here
% Nelbo and gradients for learning parameteres of features 

    
if (nargout == 1) % no grads required
    model.Phi   = feval(model.featFunc, model.X, theta); 
    
    % DELETE ME?
    model = mteugpOptimizeMeans(model);
    model = mteugpOptimizeCovariances(model);

    nelbo = getNelboFeat( model );
else
    [model.Phi, GradPhi] = feval(model.featFunc, model.X, theta); 
    
    % DELETE ME?
    model = mteugpOptimizeMeans(model);
    model = mteugpOptimizeCovariances(model);

    [nelbo, grad] = getNelboFeat(model, GradPhi);    
end
end


% Assumes feature function retuns a gradient NxDxL, where D 
% is the number of features and L is the number of parameters
function [nelbo, grad] = getNelboFeat(model, GradPhi)
Q = model.Q;

%% KL term
kl  = mteugpGetKL( model );

%% ELL term and ELBO
if (nargout == 2) % asking for gradients
    [ell, grad] = getELLAndGrad(model, GradPhi);
    
    elbo  = ell - kl; % ELBO = ELL - KL 
    nelbo = - elbo;
    grad  = - grad;
else
    ell = getELL(model);
    
    elbo = ell - kl; % ELBO = ELL - KL 
    nelbo = - elbo;
end


%% Negative ELBO and its gradients
end
 

%% Done separately to avoid if within loops for gradients
function [ell, grad] = getELLAndGrad(model, GradPhi)
% N = model.N;
ell = 0;
sigma2y     = model.sigma2y;
Sigmainv    = diag(1./(sigma2y));
M           = model.M';
P           = model.P;
[N, D, L]   = size(GradPhi);
grad        = zeros(L,1);
for n = 1 : N 
    yn       = model.Y(n,:)';
    An       = squeeze(model.A(n,:,:));
    phin     = model.Phi(n,:)';
    bn       = model.B(n,:)';
    quadTerm    = (yn - An*M*phin - bn)'*Sigmainv*(yn - An*M*phin - bn); % TODO: Improve efficiency
    gPhin    = squeeze(GradPhi(n,:,:));  % grad_theta(phin)
    
    % TODO: Should not do if here but Matlab is incosistent with dimensions
    % with Tensors
    if (L==1) 
        gPhin = gPhin'; 
    end
    grad = grad -  2*gPhin'*M'*An'*Sigmainv*(yn - An*M*phin - bn); % grad quad term

    trTerm = 0;
    for q = 1 : model.Q
        Cq = model.C(:,:,q);
        anq = An(:,q)';
        trTerm = trTerm + trace(phin*anq'*Sigmainv*anq*phin'*Cq); % TODO: improve efficiency 
        grad = grad + 2*gPhin'*Cq*phin*anq'*Sigmainv*anq;% grad of trace term
    end
    ell  = ell + quadTerm + trTerm;
    
end
    ell  = - 0.5*( ell - N*(P*log(2*pi) + sum(log(sigma2y))) ) ;
    grad = - 0.5*grad;
end


%% ell = getELL(model)
function ell = getELL(model)
N = model.N;
ell = 0;
sigma2y     = model.sigma2y;
Sigmainv    = diag(1./(sigma2y));
M           = model.M';
P           = model.P;
for n = 1 : N 
    yn       = model.Y(n,:)';
    An       = squeeze(model.A(n,:,:));
    phin     = model.Phi(n,:)';
    bn       = model.B(n,:)';
    quadTerm    = (yn - An*M*phin - bn)'*Sigmainv*(yn - An*M*phin - bn); % TODO: Improve efficiency
    
    trTerm = 0;
    for q = 1 : model.Q
        Cq = model.C(:,:,q);
        anq = An(:,q)';
        trTerm = trTerm + trace(phin*anq'*Sigmainv*anq*phin'*Cq); % TODO: improve efficiency 
    end
    ell  = ell + quadTerm + trTerm;
    
end
    ell  = - 0.5*( ell - N*(P*log(2*pi) + sum(log(sigma2y))) ) ;
end



