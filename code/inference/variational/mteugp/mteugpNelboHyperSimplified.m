function [nelbo, grad] = mteugpNelboHyperSimplified(theta, model)
% the implemented gradients are wrt precision parameters 
% lambday, lambdaw
[model, d_hyper] =  mteugpUnwrapHyperSimplified(model, theta);

% TODO: [EVB] DELETE? TEMPORARY HERE, DOES THIS ACTUALLY WORK?
%model = mteugpOptimizeMeans( model );
model = mteugpOptimizeMeansSimplified( model );

 
nelbo  = mteugpNelboSimplified( model );
if (nargout == 1) 
    return;
end


% We get here if gradients are required
[model.Phi, GradPhi] = model.featFunc(model.X, model.Z, model.featParam); 
[N, D, L] = size(GradPhi);  % L: number of feat paramters
P             = model.P;
Q             = model.Q;
D             = model.D;
M             = model.M; % posterior means : D x Q
MuF           = model.Phi*M; % Mu_f = M*Phi: N x Q
sigma2w       = model.sigma2w;
sigma2y       = model.sigma2y;
lambday       = model.lambday;

% these are the internal derivatives for chain rule
[d_f, d_y, d_w] = mteugpSplitHyper(d_hyper, P, Q);


grad_f = zeros(L,1);
grad_y = zeros(P,1);
grad_w = sum(M.*M,1)' - D*sigma2w; % 

% TODO: Vectorize code
% TODO: Some things  could be computed elsewhere (outside func)?
[Gval, J,  H] =  egpGetStats(MuF, model.fwdFunc, model.jacobian, model.diaghess, N, P, Q);
Ytilde    = model.Y - Gval;
Ys        = bsxfun(@times, Ytilde, lambday'); % NxP (Sigmay^{-1} x (Y - G) )


% Computing C for new values of Phi
C    = zeros(D, D, Q);
PcP = zeros(N,Q);
for q = 1 : Q % grad of log det term
    C(:,:,q)    =  mteugpGetCq(J(:,:,q), model.Phi, model.sigma2w(q), lambday);
    
    % Pre-compute Phi_n^T Cq Phi_n
    PcP(:,q) = diagProd(model.Phi*C(:,:,q), model.Phi');
    
    % grad_y
    v    = PcP(:,q); % Nx1
    Aq   = J(:,:,q); % NxP
    grad_y = grad_y + diagProd(Aq', bsxfun(@times, Aq, v));      
    
    % grad_w
    grad_w(q) = grad_w(q) + trace(C(:,:,q));
end

% grad_y
grad_y  = grad_y + diagProd(Ytilde',Ytilde); % quadratic term
grad_y  = grad_y - N*sigma2y; % logdet term 
grad_y  = grad_y.*d_y; % chain rule
grad_y  = 0.5*grad_y; % log precision space

%lambday =  1./model.sigma2y;
%grad_y  = 0.5*grad_y.*lambday; % log precision space

% grad_w
grad_w  = grad_w.*d_w; % chain rule
grad_w  = 0.5*grad_w; 
%lambdaw =  1./model.sigma2w;
%grad_w  = 0.5*grad_w.*lambdaw;

% grad_f
for n = 1 : N
    gPhin    = squeeze(GradPhi(n,:,:));  % grad_theta(phin) : D x L
    phin     = model.Phi(n,:)';
    % TODO: Should not do if here but Matlab is incosistent with dimensions
    % with Tensors
    if (L==1) 
        gPhin = gPhin'; 
    end
    Jn = J(n,:,:);
    grad_f = grad_f - gPhin'*M*Jn'*Ys(n,:); % grad_f of quadratic term: TODO: Vectorize
    
    for q = 1 : Q % 
        anq      =  squeeze(J(n,:,q));
       alpha_nq  =   anq'*(anq.*lambday); % 1x1
       grad_f      = grad_f +  alpha_nq*gPhin'*C(:,:,q)*phin;
       
       % implicit gradient: 
       dl_danq     = PcP(n,q)*lambday.*anq; % P x 1
       hnq         = squeeze(H(n,:,q)); % P x 1
       danq_dtheta = hnq*M(:,q)'*gPhin;  % P X L
       grad_imp    = danq_dtheta'*dl_danq;
       
       grad_f        = grad_f + grad_imp; % TODO: TRANSPOSE OF THIS?
    end
    
end

grad_f = grad_f.*d_f; % Chain rue

grad = [grad_f; grad_y; grad_w];

end
