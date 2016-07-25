function [model, nelbo, exitFlag]  = mteugpOptimizeHyperSimplified(model )
%MTEUGPOPTIMIZE  Optimize Hyper for simplefied nelbo using analytical
%gradients
%   wrapper for differenr optimization algorithms for hyperparameters
% theta = [featureParam; likelihoodParam; PriorParam]
%       = [featureParam; theta_y; theta_w]
%
% Edwin V. Bonilla (http://ebonilla.github.io/)

if (model.hyperConf.verbose)
    fprintf('Optimizing Hyper starting \n')
end

model.lambday = 1./model.sigma2y;
model.lambdaw = 1./model.sigma2w;

theta  = mteugpWrapHyperSimplified(model);

% testGradients(model, theta, 0); %pause;


optConf = model.hyperConf;
switch optConf.optimizer
    case 'minFunc',
        % numDiff = 0: use user gradients, 1: fwd-diff, 2: centra-diff
        opt = struct('Display', 'full', 'Method', 'lbfgs', ...
                'MaxIter', optConf.iter, 'MaxFunEvals', optConf.eval, ...
                'progTol', optConf.ftol, ...
                'DerivativeCheck','off', 'numDiff', 0); 

        % Using minFunc
        [theta, nelbo, exitFlag]  = minFunc(@mteugpNelboHyperSimplified, theta, opt, model); 
    
    case 'minimize',
        theta = minimize(theta, @mteugpNelboHyperSimplified, optConf.eval, model);
    
    case 'nlopt', % Using nlopt
        opt.verbose        = optConf.verbose;
        % TODO: [EVB] keep lbfgs
        opt.algorithm      = NLOPT_LD_LBFGS; 
        %opt.algorithm     = NLOPT_LN_BOBYQA;
        opt.min_objective  = @(xx) mteugpNelboHyperSimplified(xx, model);        
        opt.maxeval        = optConf.eval;
        opt.ftol_rel       = optConf.ftol; % relative tolerance in f
        opt.xtol_rel       = optConf.xtol;
        opt.lower_bounds   =   mteugpSetLB(theta, model.P, model.Q); % just to avoid numerical problems
        opt.upper_bounds   =   mteugpSetUB(theta, model.P, model.Q); % just to avoid numerical problems
        
        [theta, nelbo, exitFlag] = nlopt_optimize(opt, theta);
    
end 
 
model  = mteugpUnwrapHyperSimplified( model, theta );

if (model.hyperConf.verbose)
    fprintf('Optimizing hyper done \n');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function theta_lb = mteugpSetLB(theta, P, Q)
L          = length(theta);

nFeatParam = L - P - Q; % Number of feature parameters
theta_f    = -500*ones(nFeatParam,1); 
theta_y    = -500*ones(P,1); % lower bound on log precision
theta_w    = -500*ones(Q,1); % lower bound on log precision
theta_lb   = [theta_f; theta_y; theta_w]; 

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function theta_up = mteugpSetUB(theta, P, Q)
L          = length(theta);

nFeatParam = L - P - Q; % Number of feature parameters
theta_f    = 500*ones(nFeatParam,1); % jusy to avoid numerical problems
theta_y    = 500*ones(P,1);   % uper bound on log precision
theta_w    = 500*ones(Q,1);   % upper bound on log precision  
theta_up   = [theta_f; theta_y; theta_w]; 

end









function testGradients(model, theta, random)
order = 1;
type  = 2; 
[L, R]     =  size(theta);
if (random == 1) % theta not provided so Theta is random
    R = 100;
    val   = 5;
    theta   = -val + 2*val*rand(L,R);
end
delta = zeros(L,R);
userG = zeros(L,R);
diffG = zeros(L,R);
for r = 1 : R
    x = theta(:,r);
    [delta(:,r), userG(:,r), diffG(:,r)] = derivativeCheck(@mteugpNelboHyperSimplified, x, order, type, model);
end

userG
diffG

%hist(delta(:));



end





 














