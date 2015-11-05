function  model  = mteugpOptimizeFeatParam( model )
%MTEUGPOPTIMIZEFEATPARAM Optmizes feature parameters using simplfied nelbo
%   Detailed explanation goes here
fprintf('Optimizing feature parameters starting \n');

theta   = model.featParam; % wrapping of feat param managed by feat func

optConf = model.hyperConf;
switch optConf.optimizer
    case 'minFunc',
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
[Gval, J] =  egpGetStats(MuF, model.fwdFunc, model.jacobian, N, P, Q);
Ytilde    = model.Y - Gval;
Ys        = bsxfun(@times, Ytilde, diagSigmayinv'); % NxP (Sigmay^{-1} x (Y - G) )

% Computing C for new valeus of Phi
C = zeros(D, D, Q);
for q = 1 : Q % grad of log det term
    C(:,:,q)    =  mteugpGetCq(J(:,:,q), model.Phi, model.sigma2w(q), diagSigmayinv);
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
        alpha_nq =   anq'*(anq.*diagSigmayinv); % 1x1
       grad      = grad +  alpha_nq*gPhin'*C(:,:,q)*phin;
    end
    
end



end



function model = updateFeatures(model, theta)
model.featParam = theta;
model.Phi       = feval(model.featFunc, model.X, model.Z, model.featParam);
end





















