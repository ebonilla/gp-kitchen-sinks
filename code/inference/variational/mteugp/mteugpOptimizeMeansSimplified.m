function  model = mteugpOptimizeMeansSimplified( model )
%MTEUGPOPTIMIZEMEANSSIMPLIFIED Optimize means using simplified Nelbo
%   Detailed explanation goes here

fprintf('Optimizing Means starting \n');

theta   = model.M(:); % wrapping of feat param managed by feat func

optConf = model.varConf;
switch lower(optConf.optimizer)
    case 'minfunc',
        % numDiff = 0: use user gradients, 1: fwd-diff, 2: centra-diff
        opt = struct('Display', 'full', 'Method', 'lbfgs', ...
                'MaxIter', optConf.iter, 'MaxFunEvals', optConf.eval, ...
                'progTol', optConf.ftol, ...
                'DerivativeCheck','on', 'numDiff', 0); 
        [theta, nelbo, exitFlag]  = minFunc(@mteugpNelboMeans, theta, opt, model); 
    case 'nlopt', % Using nlopt
        opt.verbose             = optConf.verbose;
        opt.algorithm           = NLOPT_LD_LBFGS;
        opt.min_objective       = @(xx) mteugpNelboMeans(xx, model);
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
model.M = reshape(theta, model.D, model.Q);

fprintf('Optimizing Means done \n');

end

function [nelbo, grad] = mteugpNelboMeans(theta, model)
model.M = reshape(theta, model.D, model.Q);
nelbo  = mteugpNelboSimplified( model );
if (nargout == 1) 
    return;
end

% We get here if gradients are required
N             = model.N;
Q             = model.Q;
D             = model.D;
MuF             = model.Phi*model.M;
diagSigmayinv   = 1./model.sigma2y;
diagSigmawinv   = 1./model.sigma2w;   
gradM           = zeros(size(model.M));


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
        end


        % Implicit gradient here: dl_danq danq_dm
        for n = 1 : N
            phin     = model.Phi(n,:)';
            
            for q = 1 : Q
                anq         =  squeeze(J(n,:,q));
                dl_danq     = PcP(n,q)*diagSigmayinv.*anq; % P x 1
                hnq         = squeeze(H(n,:,q)); 
                danq_dmq    = hnq*phin'; %  PxD
                grad_imp    = danq_dmq'*dl_danq;
                gradM(:,q)  = gradM(:,q) + grad_imp;
            end
        end
        
        
    case 'Unscented'
       ME = MException('VerifyMethod:UnsupportedLinearMethod', ...
             'Method Unscented currently unsupported');
          throw(ME);    

end


grad = gradM(:);



end


function testGradients(model)
order = 1;
type = 2; 
L =  length(model.M(:));
R = 10;
delta = zeros(L,R);
for r = 1 : 10
    theta   = 10*randn(L,1);    
    [delta(:,r), userG, diffG] = derivativeCheck(@mteugpNelboMeans, theta, order, type, model);
end

hist(delta(:));



end










