function  model  = mteugpOptimizeSigma2y( model )
%MTEUGPOPTIMIZESIGMA2Y Optimize sigma2y using simplified nelbo
%   Detailed explanation goes here

% Using gradients
% model = mteugpOptimizeSigma2yGrad(model);
% Edwin V. Bonilla (http://ebonilla.github.io/)

model = meteugpUpdateSigma2y(model);


end


% closed form
function model = meteugpUpdateSigma2y(model)
fprintf('Updating sigma2y starting \n');
P             = model.P;
N             = model.N;
Q             = model.Q;
D             = model.D;
M             = model.M; % posterior means
MuF           = model.Phi*M; % Mu_f = M*Phi
diagSigmayinv = 1./(model.sigma2y);
[Gval, J] =  egpGetStats(MuF, model.fwdFunc, model.jacobian, model.diaghess, N, P, Q);
sigma2y   = zeros(size(model.sigma2y));
for q = 1 : model.Q % logdet{Cq^-1} term 
    Cq   =  mteugpGetCq(J(:,:,q), model.Phi, model.sigma2w(q), diagSigmayinv);
    v    = diagProd(model.Phi*Cq, model.Phi'); % Nx1
    Aq   = J(:,:,q); % NxP
    sigma2y = sigma2y + diagProd(Aq', bsxfun(@times, Aq, v));         
end
Ys    = model.Y - Gval;
sigma2y  = sigma2y + diagProd(Ys',Ys); % quadratic term
sigma2y  = sigma2y/model.N; % 

model.sigma2y  = sigma2y;

fprintf('Updating sigma2y done \n');

end
    

function model = mteugpOptimizeSigma2yGrad(model)
fprintf('Optimizing sigma2y starting \n');

theta =  mteugpWrapSigma2y(model.sigma2y);

optConf = model.hyperConf;
switch lower(optConf.optimizer)
    case 'minfunc',
        % numDiff = 0: use user gradients, 1: fwd-diff, 2: centra-diff
        opt = struct('Display', 'full', 'Method', 'lbfgs', ...
                'MaxIter', optConf.iter, 'MaxFunEvals', optConf.eval, ...
                'progTol', optConf.ftol, ...
                'DerivativeCheck','on', 'numDiff', 0); 
        [theta, nelbo, exitFlag]  = minFunc(@mteugpNelboSigma2y, theta, opt, model); 
    case 'nlopt', % Using nlopt
        opt.verbose             = optConf.verbose;
        opt.algorithm           = NLOPT_LD_LBFGS;
        opt.min_objective       = @(xx) mteugpNelboSigma2y(xx, model);
        opt.maxeval             = optConf.eval;
        opt.ftol_rel            = optConf.ftol; % relative tolerance in f
        opt.xtol_rel            = optConf.xtol;
        [theta, nelbo, retcode] = nlopt_optimize(opt, theta);       
    otherwise,
       ME = MException('VerifyOpitions:InvalidOptimizer', ...
             ['Invalid Optimizer ', optConf.optimizer ]);
          throw(ME);        
end

model.sigma2y = mteugpUnrwapSigma2y(theta);

fprintf('Optimizing sigma2y done \n');


end






function [nelbo, grad] = mteugpNelboSigma2y(theta, model)
model.sigma2y = mteugpUnrwapSigma2y(theta);
nelbo  = mteugpNelboSimplified( model );
P             = model.P;
N             = model.N;
Q             = model.Q;
D             = model.D;
M             = model.M; % posterior means
MuF           = model.Phi*M; % Mu_f = M*Phi
diagSigmayinv = 1./(model.sigma2y);

if (nargout == 2) % gradient
    grad = zeros(size(theta)); 
    [Gval, J] =  egpGetStats(MuF, model.fwdFunc, model.jacobian, model.diaghess, N, P, Q);
    for q = 1 : model.Q % logdet{Cq^-1} term 
        Cq   =  mteugpGetCq(J(:,:,q), model.Phi, model.sigma2w(q), diagSigmayinv);
        v    = diagProd(model.Phi*Cq, model.Phi'); % Nx1
        Aq   = J(:,:,q); % NxP
        grad = grad + diagProd(Aq', bsxfun(@times, Aq, v));         
    end
    Ys    = model.Y - Gval;
    grad  = grad + diagProd(Ys',Ys); % quadratic term
    
    grad = grad - model.N*model.sigma2y; % logdet term
    
    lambday =  1./model.sigma2y;
    grad    = 0.5*grad.*lambday; % log precision space
end


end































