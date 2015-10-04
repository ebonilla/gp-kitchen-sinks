function [ ell ] = mteugpGetELL( model )
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


