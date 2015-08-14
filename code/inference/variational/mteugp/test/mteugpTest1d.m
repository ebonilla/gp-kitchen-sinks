function mteugpTest1d()

path(path(), genpath('~/Dropbox/Matlab/utils')); % sq_dist from here
path(path(), genpath('~/Dropbox/Matlab/gpml-matlab-v3.6-2015-07-07'));
path(path(), genpath('~/Dropbox/Matlab/DERIVESTsuite'));

rng(10101,'twister');

%% General settings
N       = 20;
d       = 1; % original dimensionality of input space
D       = 1000; % dimensionality of output space
covfunc = 'covSEiso';
ell     = 1/2; 
sf      = 1; 
hyp.cov = log([ell; sf]);
sigma2y = 1e-3; 
sigma2w = 1;

%% Generates data
[x, xstar, y, K, cholK] =   getData(N, d, covfunc, hyp, sigma2y);

%% Generates random Features 
Z       = randn(D,d);
sigma_z = getOptimalSigmaz(ell);
PHI     = getRandomRBF(Z, sigma_z, x);

%% set up model
model.Q       = 1; % latent functions
model.P       = size(y,2); % Outputs
model.N       = N; 
model.D       = D;
model.sigma2y = sigma2y;
model.sigma2w = sigma2w;
model.Y       = y;
model.Phi     = PHI;
optconf.maxiter = 100;
optconf.tol    = 1e-3;
optconf.alpha  = 0.01; 

model         = mteugpLearn( model, optconf );

end



%%  function getData()
function [x, xstar, y, K, L] =  getData(N, d, covfunc, hyp, sigma2y)
%% Generates input
x            = -2 + 4*rand(N, d);
if ( d == 1 )
    x = sort(x);
end
xstar = linspace(-2, 2, 100)';
K = feval(covfunc, hyp.cov, x);
L  = chol(K + sigma2y*eye(N,N), 'lower');
Z  = randn(N,1);
f  = L*Z;
y  = f;

end