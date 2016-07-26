function ell = mteugpGetELL(model)
% MTEUGPGETELL Computes expected log likelihood for a given model
% Edwin V. Bonilla (http://ebonilla.github.io/)

sigma2y      = model.sigma2y;
diagSigmaInv = 1./(sigma2y);
P            = model.P;
N            = model.N;
Q            = model.Q;
D            = model.D;

%% Quadratic term
PhiM    = model.Phi*model.M; % N*Q
C = zeros(N, P);
for p = 1 : P
    Ap     = squeeze(model.A(:,p,:));
    C(:,p) = sum(Ap.*PhiM,2);
end
C        = model.Y - C - model.B;
quadTerm = sum(sum(bsxfun(@times,C, diagSigmaInv').*C)); % quad term

%% Trace term
C1 = zeros(N, Q);
C2 = zeros(N, Q);
for  q = 1 : Q
    C1(:,q) = diagProd(model.Phi, model.C(:,:,q)*model.Phi');
    C2(:,q) = sum(bsxfun(@times,model.A(:,:,q), diagSigmaInv').*model.A(:,:,q),2);  
end
trTerm = sum(sum(C1.*C2));

ell  =   quadTerm + trTerm;

ell = -0.5*( ell + N*(P*log(2*pi) + sum(log(sigma2y))) ) ;

end

function [ ell ] = mteugpGetELLOld( model )
%MTEUGPGETELL Summary of this function goes here
%   Detailed explanation goes here
N = model.N;
ell = 0;
sigma2y  = model.sigma2y;
Sigmainv = diag(1./(sigma2y));
M        = model.M';
P        = model.P;
for n = 1 : N 
    yn       = model.Y(n,:)';
    An       = squeeze(model.A(n,:,:));
    phin     = model.Phi(n,:)';
    bn       = model.B(n,:)';
    quadTerm    = (yn - An*M*phin - bn)'*Sigmainv*(yn - An*M*phin - bn); % TODO: Improve efficiency
    
     trTerm = 0;
    for q = 1 : model.Q
        Cq = model.C(:,:,q);
        %anq = An(:,q)';
        anq = An(:,q);
        trTerm = trTerm + trace(phin*anq'*Sigmainv*anq*phin'*Cq); % TODO: improve efficiency 
    end
    ell  = ell + quadTerm + trTerm;
end
ell = -0.5*( ell + N*(P*log(2*pi) + sum(log(sigma2y))) ) ;

end


