function model = mteugpOptimizeSigma2w( model )
%MTEUGPOPTIMIZESIGMA2W Optimize sigma2w using simplified nelbo
%   Detailed explanation goes here
% Edwin V. Bonilla (http://ebonilla.github.io/)

fprintf('Optimizing sigma2w starting \n');

theta =  mteugpWrapSigma2w(model.sigma2w);

optConf = model.hyperConf;
switch lower(optConf.optimizer)
    case 'minfunc',
        % numDiff = 0: use user gradients, 1: fwd-diff, 2: centra-diff
        opt = struct('Display', 'full', 'Method', 'lbfgs', ...
                'MaxIter', optConf.iter, 'MaxFunEvals', optConf.eval, ...
                'progTol', optConf.ftol, ...
                'DerivativeCheck','on', 'numDiff', 0); 
        [theta, nelbo, exitFlag]  = minFunc(@mteugpNelboSigma2w, theta, opt, model); 
    case 'nlopt', % Using nlopt
        opt.verbose             = optConf.verbose;
        opt.algorithm           = NLOPT_LD_LBFGS;
        opt.min_objective       = @(xx) mteugpNelboSigma2w(xx, model);
        opt.maxeval             = optConf.eval;
        opt.ftol_rel            = optConf.ftol; % relative tolerance in f
        opt.xtol_rel            = optConf.xtol;
        opt.lower_bounds        =   -100*ones(size(theta)); % just to avoid numerical problems
        [theta, nelbo, retcode] = nlopt_optimize(opt, theta);       
    otherwise,
       ME = MException('VerifyOpitions:InvalidOptimizer', ...
             ['Invalid Optimizer ', optConf.optimizer ]);
          throw(ME);        
end

model.sigma2w = mteugpUnrwapSigma2w(theta);

fprintf('Optimizing sigma2w done \n');

end




function [nelbo, grad] = mteugpNelboSigma2w(theta, model)
model.sigma2w = mteugpUnrwapSigma2w(theta);
nelbo  = mteugpNelboSimplified( model );
P             = model.P;
N             = model.N;
Q             = model.Q;
D             = model.D;
M             = model.M; % posterior means
MuF           = model.Phi*M; % Mu_f = M*Phi
diagSigmayinv = 1./(model.sigma2y);

if (nargout == 2) % gradient
    [Gval, J] =  egpGetStats(MuF, model.fwdFunc, model.jacobian, model.diaghess, N, P, Q);
    grad = sum(M.*M,1)' - D*model.sigma2w;
    for q = 1 : model.Q
        Cq  =  mteugpGetCq(J(:,:,q), model.Phi, model.sigma2w(q), diagSigmayinv);
        grad(q) = grad(q) + trace(Cq);
    end
    lambdaw =  1./model.sigma2w;
    grad    = 0.5*grad.*lambdaw;
end


end













