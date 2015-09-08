function  H  = mteugpGetHessMq( model, mq, sigma2w, diagSigmainv, N, q )
%MTEUGPGETHESSMQ Summary of this function goes here
%   Get Hessian of negative elbo evaluated at w_q = m_q
% diagSigmaInv: Px1 vector of diagonal terms (Sigma_y)^-1
% and the code is fully vectorized

D = model.D;
H =  - (1/sigma2w) * eye(D);
%for n = 1 : N
%    phin = model.Phi(n,:)';
%    anq  = model.A(n,:,q)';
%    H    = H - phin*anq'*Sigmainv*anq*phin'; 
%end
Aq  = model.A(:,:,q); % NxP
Phi = model.Phi; % NxD
v = diagProd(bsxfun(@times, Aq, diagSigmainv'), Aq'); % Nx1
H = H - (bsxfun(@times,Phi', v')*Phi);

% minimizing negative elbo
H = - H;

end














