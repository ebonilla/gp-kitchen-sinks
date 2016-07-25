function grad_mq = mteugpGetGradMq(model, mq, sigma2w, diagSigmainv, N, q)
% Edwin V. Bonilla (http://ebonilla.github.io/)

grad_mq = - (1/sigma2w)*mq;

Aq    = model.A(:,:,q); % NxP
PhiMq = model.Phi*mq; %  Nx1
LHS = model.Y - bsxfun(@times, Aq, PhiMq) - model.B; % NxP
RHS = bsxfun(@times, Aq, diagSigmainv'); % NxP
g       = sum(LHS.*RHS,2); % Nx1
grad_mq =  grad_mq  + sum(bsxfun(@times, model.Phi, g),1)';

grad_mq = - grad_mq;
end



function grad_mq = mteugpGetGradMqOld(model, mq, sigma2w, diagSigmainv, N, q)
%% grad_mq = getGradMq(model, mq, sigma2w, Sigmainv, N, q)
grad_mq = - (1/sigma2w)*mq;
for n = 1 : N
    yn       = model.Y(n,:)';
    phin     = model.Phi(n,:)';
    anq      = model.A(n,:,q)';
    bn       = model.B(n,:)';
    grad_mq  =  grad_mq + phin*(anq'.*diagSigmainv')*(yn - anq*mq'*phin - bn);                 
end


% minimizing negative ebo
grad_mq = - grad_mq;

end


