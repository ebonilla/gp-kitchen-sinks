function model = mteugpTestNonLinear()
% 1D, Nonlinear
clc; close all;

rng(10101,'twister');

%% General settings
N       = 50;
d       = 1; % original dimensionality of input space
D       = 100; % dimensionality of output space
covfunc = 'covSEiso';
ell     = 1/2; 
sf      = 1; 
hyp.cov = log([ell; sf]);
sigma2y = 1e-3; 
sigma2w = 1;
fwdFunc = @(ff) ff.^3;

%% Generates data
[x, y, xstar, fstar, gstar, ystar] =   getData(N, d, covfunc, hyp, fwdFunc, sigma2y);




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
model.nSamples     = 1000;
optconf.varIter    = 100;  % maximum iterations on variational parameters
optconf.globalIter = 1;    % maximum global iterations
optconf.tol        = 1e-5; % tolerance for Newton iterations
optconf.alpha      = 0.5;  % learning rate for Newton iterations

%% Learns EGP model
model         = mteugpLearn( model, optconf );


%% Evaluate predictive distribution over fstar, and also gstar predictions
PhiStar         = getRandomRBF(Z, sigma_z, xstar);
[mPred, vPred]  =  mteugpGetPredictive( model, PhiStar );
gstar            = mteugpPredict( model, mPred, vPred ); % 
plot_confidence_interval(xstar,mPred,sqrt(vPred), [], 1, 'b', [0.7 0.9 0.95]); 
hold on; 
plot(xstar, gstar, 'k--', 'LineWidth', 2); hold on;  
plot_data(x, y, xstar, fstar, gstar); hold on;
legend({'EGP std (f*)', 'EGP mean(f*)', 'EGP mean(g*)', 'ftrue', 'gtrue', ...
    'ytrain'}, 'Location', 'SouthEast');


end



%  function getData()
function [x, y, xstar, fstar, gstar, ystar] =  getData(N, d, covfunc, hyp, fwdFunc, sigma2y)
MIN_NOISE = 1e-7;
Nall   = 300;
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


end

%
function plot_data(x, y, xstar, fstar, gstar )
[v, idx] = sort(xstar);
plot(v, fstar(idx), 'r', 'LineWidth',2); hold on;
plot(v, gstar, 'g','LineWidth',2); hold on;
plot(x, y, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k'); % data
set(gca, 'FontSize', 14);
end





























