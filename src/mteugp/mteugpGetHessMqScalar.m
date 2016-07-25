function  H  = mteugpGetHessMqScalar( model, mq, sigma2w, diagSigmainv, N, q )
%MTEUGPGETHESSMQSCALAR Scalar version (loop over n)
%
%   Get Hessian of negative elbo evaluated at w_q = m_q
% Sigmainv: (Sigma_y)^-1
% Edwin V. Bonilla (http://ebonilla.github.io/)

D = model.D;
H =  - (1/sigma2w) * eye(D);
for n = 1 : N
    phin = model.Phi(n,:)';
    anq  = model.A(n,:,q)';
    H    = H - phin*(anq'.*diagSigmainv)*anq*phin'; 
end

% minimizing negative elbo
H = - H;

end



