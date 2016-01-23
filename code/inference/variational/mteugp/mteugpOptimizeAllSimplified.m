function  [model, nelbo, exitFlag] = mteugpOptimizeAllSimplified( model )
%MTEUGPOPTIMIZEMEANSSIMPLIFIED Optimize all the parameters jointly
% using simplified Nelbo
%   Detailed explanation goes here

fprintf('Optimizing all parameters starting \n');

theta_m   = model.M(:); % wrapping of feat param managed by feat func
theta_h   = mteugpWrapHyperSimplified(model);
theta = [theta_m; theta_h];

% Getting optimization bounds
[lb_m, ub_m] = get_mean_bounds(theta_m);
[lb_h, ub_h] = get_hyper_bounds(theta_h, model.P, model.Q);
lb = [lb_m; lb_h]; 
ub = [ub_m; ub_h];


optConf = model.varConf;
switch lower(optConf.optimizer)
    case 'minfunc',
        % numDiff = 0: use user gradients, 1: fwd-diff, 2: centra-diff
        opt = struct('Display', 'full', 'Method', 'lbfgs', ...
                'MaxIter', optConf.iter, 'MaxFunEvals', optConf.eval, ...
                'progTol', optConf.ftol, ...
                'DerivativeCheck','off', 'numDiff', 0); 
        [theta, nelbo, exitFlag]  = minFunc(@mteugpNelboAll, theta, opt, model); 
    case 'nlopt', % Using nlopt
        opt.verbose             = optConf.verbose;
        opt.algorithm           = NLOPT_LD_LBFGS;
        opt.min_objective       = @(xx) mteugpNelboAll(xx, model);
        opt.maxeval             = optConf.eval;
        opt.ftol_rel            = optConf.ftol; % relative tolerance in f
        opt.xtol_rel            = optConf.xtol;
        opt.lower_bounds        = lb;
        opt.upper_bounds        = ub;
        [theta, nelbo, exitFlag] = nlopt_optimize(opt, theta);     
    otherwise,
       ME = MException('VerifyOpitions:InvalidOptimizer', ...
             ['Invalid Optimizer ', optConf.optimizer ]);
          throw(ME);             
end

l_m          = length(theta_m);
theta_m_opt = theta(1:l_m);
model.M     = reshape(theta_m_opt, model.D, model.Q);
theta_h_opt = theta(l_m+1:end);
model       = mteugpUnwrapHyperSimplified( model, theta_h_opt );

fprintf('Optimizing All done \n');

end

function [lb, ub] = get_mean_bounds(theta_m)
L = length(theta_m);
lb = -inf*ones(L,1);
ub = inf*ones(L,1);

end

function [lb, ub] = get_hyper_bounds(theta_h, P, Q)
L = length(theta_h);
nFeatParam = L - P - Q; % Number of feature parameters
theta_f    = -500*ones(nFeatParam,1); 
theta_y    = -500*ones(P,1); % lower bound on log precision
theta_w    = -500*ones(Q,1); % lower bound on log precision
lb   = [theta_f; theta_y; theta_w]; 

theta_f    = 500*ones(nFeatParam,1); % jusy to avoid numerical problems
theta_y    = 500*ones(P,1);   % uper bound on log precision
theta_w    = 500*ones(Q,1);   % upper bound on log precision  
ub   = [theta_f; theta_y; theta_w]; 


end



function [nelbo, grad] = mteugpNelboAll(theta, model)
D             = model.D;
Q             = model.Q;
l_m           = D*Q;
theta_m       = theta(1:l_m);
model.M       = reshape(theta_m, D, Q);
theta_h       = theta(l_m+1:end);
model         = mteugpUnwrapHyperSimplified( model, theta_h );
nelbo   = mteugpNelboSimplified( model );
if (nargout == 1) 
    return;
end

%% We get here if gradients are required
P                    = model.P;
N                    = model.N;
D                    = model.D;
M                    = model.M;
MuF                  = model.Phi*M;
[model.Phi, GradPhi] = model.featFunc(model.X, model.Z, model.featParam); 
[~, ~, L]            = size(GradPhi);  % L: number of feat paramters
diagSigmayinv        = 1./model.sigma2y;
diagSigmawinv        = 1./model.sigma2w;   

%% gradient initilization
gradM  = zeros(size(M));
grad_f = zeros(L,1);
grad_y = zeros(P,1);
grad_w = sum(M.*M,1)' - D*model.sigma2w;


switch (model.linearMethod)
    case 'Taylor',
        [Gval, J, H] =  egpGetStats(MuF, model.fwdFunc, model.jacobian, model.diaghess, model.N, model.P, model.Q);
        Ytilde    = model.Y - Gval;
        Ys        = bsxfun(@times, Ytilde, diagSigmayinv); % NxP
        Ms        = bsxfun(@times, model.M, diagSigmawinv); % DxQ        
        for q = 1 : model.Q
            Jq         = J(:,:,q); % N x P
           gradM(:,q)  = - model.Phi'*sum(Jq.*Ys, 2); % Dx1
        end
        gradM = gradM  + Ms;

        % Computing C for new values of J
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

        % Implicit gradient here: dl_danq danq_dm
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
             
            for q = 1 : Q
                anq       =  squeeze(J(n,:,q));
                alpha_nq  =   anq'*(anq.*diagSigmayinv); % 1x1
                grad_f    = grad_f +  alpha_nq*gPhin'*C(:,:,q)*phin;
                
                % implicitgrad
                dl_danq       = PcP(n,q)*diagSigmayinv.*anq; % P x 1
                hnq           = squeeze(H(n,:,q)); 
                danq_dmq      = hnq*phin'; %  PxD
                danq_dphi     = hnq*M(:,q)'*gPhin;  % P X L
                grad_m_imp    = danq_dmq'*dl_danq;
                grad_phi_imp  = danq_dphi'*dl_danq;
                
                grad_f      = grad_f + grad_phi_imp; % TODO: TRANSPOSE OF THIS?                
                gradM(:,q)  = gradM(:,q) + grad_m_imp;
            end
        end
        
        
    case 'Unscented'
       ME = MException('VerifyMethod:UnsupportedLinearMethod', ...
             'Method Unscented currently unsupported');
          throw(ME);    

end

grad_m = gradM(:);
grad_h = [grad_f; grad_y; grad_w];

grad   = [grad_m; grad_h];

end



function testGradients(model)
order = 1;
type = 2; 
L =  length(model.M(:));
R = 10;
delta = zeros(L,R);
for r = 1 : 10
    theta   = 10*randn(L,1);    
    [delta(:,r), userG, diffG] = derivativeCheck(@mteugpNelboAll, theta, order, type, model);
end

hist(delta(:));



end










