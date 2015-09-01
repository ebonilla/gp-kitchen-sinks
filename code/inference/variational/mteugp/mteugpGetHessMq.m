function  H  = mteugpGetHessMq( model, mq, sigma2w, Sigmainv, N, q )
%MTEUGPGETHESSMQ Summary of this function goes here
%   Get Hessian of negative elbo evaluated at w_q = m_q

D = model.D;
H =  - (1/sigma2w) * eye(D);
for n = 1 : N
    phin = model.Phi(n,:)';
    anq  = model.A(n,:,q)';
    H    = H - phin*anq'*Sigmainv*anq*phin'; 
end

% minimizing negative elbo
H = - H;

end



