function mteugpTest1d()

path(path(), genpath('~/Dropbox/Matlab/utils')); % sq_dist from here
path(path(), genpath('~/Dropbox/Matlab/gpml-matlab-v3.6-2015-07-07'));
path(path(), genpath('~/Dropbox/Matlab/DERIVESTsuite'));

rng(10101,'twister');

%% General settings
N       = 20;
d       = 1; % original dimensionality of input space
D       = 100; % dimensionality of output space
covfunc = 'covSEiso';
ell     = 1/2; 
sf      = 1; 
hyp.cov = log([ell; sf]);
sigma2y = 1e-4; 
sigma2w = 1;
fwdFunc = @(ff) ff.^2;

%% Generates data
[x, y, xstar, ystar] =   getData(N, d, covfunc, hyp, fwdFunc, sigma2y);




%% Generates random Features 
Z       = randn(D,d);
sigma_z = getOptimalSigmaz(ell);
PHI     = getRandomRBF(Z, sigma_z, x);
D       = size(PHI,2); % ACtual number of features

%% set up model
model.Q            = 1; % latent functions
model.P            = size(y,2); % Outputs
model.N            = N; 
model.D            = D;
model.sigma2y      = sigma2y*ones(model.P,1); % vector of noise variances
model.sigma2w      = sigma2w*ones(D,1); % vector of prior variances
model.Y            = y;
model.Phi          = PHI;
model.linearMethod = 'Taylor';
model.fwdFunc      = fwdFunc;
optconf.maxiter    = 100;
optconf.tol        = 1e-3;
optconf.alpha      = 0.5; 

model         = mteugpLearn( model, optconf );

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






























