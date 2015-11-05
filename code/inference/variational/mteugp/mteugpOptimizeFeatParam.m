function  model  = mteugpOptimizeFeatParam( model )
%MTEUGPOPTIMIZEFEATPARAM Optmizes feature parameters using simplfied nelbo
%   Detailed explanation goes here
fprintf('Optimizing feature parameters starting \n');

theta   = model.featParam; % wrapping of feat param managed by feat func

optConf = model.hyperConf;
switch lower(optConf.optimizer)
    case 'minfunc',
        % numDiff = 0: use user gradients, 1: fwd-diff, 2: centra-diff
        opt = struct('Display', 'full', 'Method', 'lbfgs', ...
                'MaxIter', optConf.iter, 'MaxFunEvals', optConf.eval, ...
                'progTol', optConf.ftol, ...
                'DerivativeCheck','on', 'numDiff', 0); 
        [theta, nelbo, exitFlag]  = minFunc(@mteugpNelboFeatParam, theta, opt, model); 
    case 'nlopt', % Using nlopt
        opt.verbose             = optConf.verbose;
        opt.algorithm           = NLOPT_LD_LBFGS;
        opt.min_objective       = @(xx) mteugpNelboFeatParam(xx, model);
        opt.maxeval             = optConf.eval;
        opt.ftol_rel            = optConf.ftol; % relative tolerance in f
        opt.xtol_rel            = optConf.xtol;
        [theta, nelbo, retcode] = nlopt_optimize(opt, theta);     
    otherwise,
       ME = MException('VerifyOpitions:InvalidOptimizer', ...
             ['Invalid Optimizer ', optConf.optimizer ]);
          throw(ME);             
end

% update features
model = updateFeatures(model, theta);

fprintf('Optimizing feature parameters done \n');

end


function [nelbo, grad] = mteugpNelboFeatParam(theta, model)
model  = updateFeatures(model, theta);
nelbo  = mteugpNelboSimplified( model );

if (nargout == 1) 
    return;
end

% We get here if gradients are required
[Phi, GradPhi] = feval(model.featFunc, model.X, model.Z, model.featParam); 
[N, D, L] = size(GradPhi);  % L: number of feat paramters
P             = model.P;
Q             = model.Q;
D             = model.D;
M             = model.M; % posterior means : D x Q
MuF           = model.Phi*M; % Mu_f = M*Phi: N x Q
diagSigmayinv = 1./(model.sigma2y);
  
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
    
end


grad = zeros(L,1);
for n = 1 : N
    gPhin    = squeeze(GradPhi(n,:,:));  % grad_theta(phin) : D x L
    phin     = model.Phi(n,:)';
    % TODO: Should not do if here but Matlab is incosistent with dimensions
    % with Tensors
    if (L==1) 
        gPhin = gPhin'; 
    end
    Jn = J(n,:,:);
    grad = grad - gPhin'*M*Jn'*Ys(n,:); % grad of quadratic term: TODO: Vectorize
    
    for q = 1 : Q % grad of log det term
        anq      =  squeeze(J(n,:,q));
       alpha_nq  =   anq'*(anq.*diagSigmayinv); % 1x1
       grad      = grad +  alpha_nq*gPhin'*C(:,:,q)*phin;
       
       % implicit gradient
       dl_danq     = PcP(n,q)*diagSigmayinv.*anq; % P x 1
       hnq         = squeeze(H(n,:,q));
       danq_dtheta = hnq*M(:,q)'*gPhin;  % P X L
       grad_imp    = dl_danq'*danq_dtheta;
       
       grad        = grad + grad_imp;
    end
    
end



end



function model = updateFeatures(model, theta)
model.featParam = theta;
model.Phi       = feval(model.featFunc, model.X, model.Z, model.featParam);
end





















