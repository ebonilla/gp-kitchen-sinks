function nelbo  = mteugpNelbo( model )
%MTEUGPNELBO Summary of this function goes here
%   Detailed explanation goes here

Q = model.Q;
P = model.P;

%% KL part
kl = 0;
for q = 1 : Q
    kl = kl + getSingleKL(model, q);
end

%% ELL Part
ell = getELL(model);

elbo = ell - kl;


nelbo = - elbo;
end


%%
function ell = getELL(model)
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
    qTerm    = (yn - An*M*phin - bn)'*Sigmainv*(yn - An*M*phin - bn); % TODO: Improve efficiency
    
    trTerm = 0;
    for q = 1 : model.Q
        Cq = model.C(:,:,q);
        anq = An(:,q)';
        trTerm = trTerm + trace(phin*anq'*Sigmainv*anq*phin'*Cq); % TODO: improve efficiency 
    end
    ell  = qTerm + trTerm;
end
    ell = -0.5*( ell - N*(P*log(2*pi) + sum(log(sigma2y))) ) ;

end

%%  function kl = getSingleKL(model, q)
function kl = getSingleKL(model, q)
D = model.D; % dimensionality of new features (bases)
C      = model.C(:,:,q); % posterior covariance
m      = model.M(:,q); % posterior mean
cholC  = chol(C, 'lower');
sigma2w = model.sigma2w(q);
kl     = (1/sigma2w)*trace(C) ...
             + (1/sigma2w)*(m'*m) ... 
             - getLogDetChol(cholC) ...
             + D*log(sigma2w) ...
             -D;
kl     = 0.5*kl;         

end



