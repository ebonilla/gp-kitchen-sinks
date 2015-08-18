function model = mteugpTest1d()
clc; close all;

rng(10101,'twister');

%% General settings
N       = 20;
d       = 1; % original dimensionality of input space
D       = 100; % dimensionality of output space
covfunc = 'covSEiso';
ell     = 1/2; 
sf      = 1; 
hyp.cov = log([ell; sf]);
sigma2y = 1e-3; 
sigma2w = 1;
fwdFunc = @(ff) ff;

%% Generates data
[x, y, xstar, ystar] =   getData(N, d, covfunc, hyp, fwdFunc, sigma2y);




%% Generates random Features 
Z       = randn(D,d);
sigma_z = getOptimalSigmaz(ell);
Phi     = getRandomRBF(Z, sigma_z, x);
D       = size(Phi,2); % ACtual number of features

%% set up model
model.Q            = 1; % latent functions
model.P            = size(y,2); % Outputs
model.N            = N; 
model.D            = D;
model.sigma2y      = sigma2y*ones(model.P,1); % vector of noise variances
model.sigma2w      = sigma2w*ones(D,1); % vector of prior variances
model.Y            = y;
model.Phi          = Phi;
model.linearMethod = 'Taylor';
model.fwdFunc      = fwdFunc;
optconf.varIter    = 100; % maximum iterations on variational parameters
optconf.globalIter = 1;  % maximum global iterations
optconf.tol        = 1e-5;
optconf.alpha      = 0.5; 

model         = mteugpLearn( model, optconf );


%% Evaluate predictive distribution over fstar
PhiStar         = getRandomRBF(Z, sigma_z, xstar);
[ mPred, CovPred ] = mteugpGetPosteriorF( model, 1, PhiStar );
vPred = diag(CovPred);
[mGP, vGP] =  predictGP(covfunc, hyp, sigma2y, x, y, xstar);
figure;
plot_confidence_interval(xstar,mPred,sqrt(vPred), [], 1, 'b', [0.7 0.9 0.95]); 
hold on;
plot_confidence_interval(xstar, mGP, sqrt(vGP), [], 0, 'r', 'r'); hold on;
plot(x, y, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k'); % data

end



%% Gets GP posterior for linear case y = f + noise
function [mPredGP, varPredGP] =  predictGP(covfunc, hyp, sigma2y, x, y, xstar)
N = size(x,1);
K      = feval(covfunc, hyp.cov, x);
cholK  = chol(K + sigma2y*eye(N,N), 'lower');
kstar   = feval(covfunc, hyp.cov, x, xstar);
mPredGP = kstar'*(solve_chol(cholK',y)); 
% now the variances
kss       = feval(covfunc, hyp.cov, xstar, 'diag'); % only diagonal requested
v         = cholK\kstar;
varPredGP = kss - sum(v.*v, 1)'; 
end


%%  function getData()
function [x, y, xstar, fstar, gstar, ystar] =  getData(N, d, covfunc, hyp, fwdFunc, sigma2y)
MIN_NOISE = 1e-7;
Nall   = 100;
xstar  = linspace(-2, 2, Nall)';
K      = feval(covfunc, hyp.cov, xstar);
L      = chol(K + MIN_NOISE*eye(Nall), 'lower');
z      = randn(Nall,1);
fstar  = L*z;
gstar  = feval(fwdFunc, fstar); 
ystar  = gstar + sqrt(sigma2y)*randn(size(gstar));

idx   = randperm(Nall);
idx   = idx(1:N);
x     = xstar(idx,:);
y     = ystar(idx,:);
xstar(idx,:) = [];
ystar(idx,:) = [];
gstar(idx,:) = [];
fstar(idx,:) = [];

[v, idx] = sort(xstar);
plot(v, fstar(idx), 'b', 'LineWidth',2); hold on;
plot(v, gstar, 'g--','LineWidth',2); hold on;
plot(x, y, 'ro'); hold on;

legend({'fstar', 'gstar', 'ytrain' });
set(gca, 'FontSize', 14);
end






























