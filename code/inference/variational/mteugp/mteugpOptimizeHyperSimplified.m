function model  = mteugpOptimizeHyperSimplified(model )
%MTEUGPOPTIMIZE  Optimize Hyper for simplefied nelbo using analytical
%gradients
%   wrapper for differenr optimization algorithms for hyperparameters
% theta = [featureParam; likelihoodParam; PriorParam]
%       = [featureParam; theta_y; theta_w]
%
 
fprintf('Optimizing Hyper starting \n')

theta  = mteugpWrapHyper(model);

optConf = model.hyperConf;
switch optConf.optimizer
    case 'minFunc',
        % numDiff = 0: use user gradients, 1: fwd-diff, 2: centra-diff
        opt = struct('Display', 'full', 'Method', 'lbfgs', ...
                'MaxIter', optConf.iter, 'MaxFunEvals', optConf.eval, ...
                'progTol', optConf.ftol, ...
                'DerivativeCheck','off', 'numDiff', 0); 

        % Using minFunc
        [theta, nelboFeat, exitFlag]  = minFunc(@mteugpNelboHyperSimplified, theta, opt, model); 
    
    case 'minimize',
        theta = minimize(theta, @mteugpNelboHyperSimplified, optConf.eval, model);
    
    case 'nlopt', % Using nlopt
        opt.verbose        = optConf.verbose;
        opt.algorithm      = NLOPT_LD_LBFGS;        
        opt.min_objective  = @(xx) mteugpNelboHyperSimplified(xx, model);        
        opt.maxeval        = optConf.eval;
        opt.ftol_rel       = optConf.ftol; % relative tolerance in f
        opt.xtol_rel       = optConf.xtol;
        opt.lower_bounds   =   mteugpSetLB(theta, model.P, model.Q); % just to avoid numerical problems
        opt.upper_bounds   =   mteugpSetUB(theta, model.P, model.Q); % just to avoid numerical problems
        
        [theta, fminval, retcode] = nlopt_optimize(opt, theta);
    
end 
 
 model  = mteugpUnwrapHyper( model, theta );

fprintf('Optimizing hyper done \n');
end

function theta_lb = mteugpSetLB(theta, P, Q)
L          = length(theta);

nFeatParam = L - P - Q; % Number of feature parameters
theta_f    = -500*ones(nFeatParam,1); 
theta_y    = 30*ones(P,1); % upper bound on variance
theta_w    = -500*ones(Q,1); % upper bound on variance
theta_lb   = [theta_f; theta_y; theta_w]; 

end

function theta_up = mteugpSetUB(theta, P, Q)
L          = length(theta);

nFeatParam = L - P - Q; % Number of feature parameters
theta_f    = 500*ones(nFeatParam,1); % jusy to avoid numerical problems
theta_y    = 500*ones(P,1); % 
theta_w    = 500*ones(Q,1); % 
theta_up   = [theta_f; theta_y; theta_w]; 

end






function [nelbo, grad] = mteugpNelboHyperSimplified(theta, model)
model =  mteugpUnwrapHyper(model, theta);
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
diagSigmayinv = 1./(model.sigma2y);

grad_f = zeros(L,1);
grad_y = zeros(P,1);
grad_w = sum(M.*M,1)' - D*model.sigma2w;

% TODO: Vectorize code
% TODO: Some things  could be computed elsewhere (outside func)?
[Gval, J,  H] =  egpGetStats(MuF, model.fwdFunc, model.jacobian, model.diaghess, N, P, Q);
Ytilde    = model.Y - Gval;
Ys        = bsxfun(@times, Ytilde, diagSigmayinv'); % NxP (Sigmay^{-1} x (Y - G) )


% Computing C for new values of Phi
C    = zeros(D, D, Q);
PcP = zeros(N,Q);
for q = 1 : Q % grad of log det term
    C(:,:,q)    =  mteugpGetCq(J(:,:,q), model.Phi, model.sigma2w(q), diagSigmayinv);
    
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
grad_y  = grad_y - model.N*model.sigma2y; % logdet term
lambday =  1./model.sigma2y;
grad_y  = 0.5*grad_y.*lambday; % log precision space

% grad_w
lambdaw =  1./model.sigma2w;
grad_w  = 0.5*grad_w.*lambdaw;

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
       alpha_nq  =   anq'*(anq.*diagSigmayinv); % 1x1
       grad_f      = grad_f +  alpha_nq*gPhin'*C(:,:,q)*phin;
       
       % implicit gradient: 
       dl_danq     = PcP(n,q)*diagSigmayinv.*anq; % P x 1
       hnq         = squeeze(H(n,:,q)); % P x 1
       danq_dtheta = hnq*M(:,q)'*gPhin;  % P X L
       grad_imp    = danq_dtheta'*dl_danq;
       
       grad_f        = grad_f + grad_imp; % TODO: TRANSPOSE OF THIS?
    end
    
end


grad = [grad_f; grad_y; grad_w];

end



function testGradients(model)
order = 1;
type = 2; 
theta  = mteugpWrapHyper(model);
L =  length(theta);
R = 100;
Theta   = -5 + 5*rand(L,R);
delta = zeros(L,R);
userG = zeros(L,R);
diffG = zeros(L,R);
for r = 1 : R
    theta = Theta(:,r);
    [delta(:,r), userG(:,r), diffG(:,r)] = derivativeCheck(@mteugpNelboHyperSimplified, theta, order, type, model);
end

hist(delta(:));



end




















