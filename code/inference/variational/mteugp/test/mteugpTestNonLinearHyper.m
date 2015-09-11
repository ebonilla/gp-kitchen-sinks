function model = mteugpTestNonLinearHyper()
% 1D, Nonlinear, hyperpatameter learning
%
clc; close all;
   
rng(10101,'twister');

%% General settings
N       = 100;
d       = 1; % original dimensionality of input space
D       = 100; % dimensionality of output space
covfunc = 'covSEiso';
ell     = 1/2; 
sf      = 1; 
hyp.cov = log([ell; sf]);
sigma2y = 1e-3; 
sigma2w = 1;
fwdFunc = @(ff) ff.^3;
linearMethod = 'Taylor';

%% Generates data
[X, Y, xstar, fstar, gstar, ystar] =   getData(N, d, covfunc, hyp, fwdFunc, sigma2y);

model  = mteugpGetConfigDefault( X, Y, fwdFunc, linearMethod, D );





%% Learns EGP model
model         = mteugpLearn( model );
sigma_z       = getOptimalSigmaz(ell); 
fprintf('sigma_x: Learned= %.4f <--> Optimal %.4f \n', exp(model.featParam), sigma_z);
fprintf('sigma2_y: Learned= %.4f <--> True %.4f \n', model.sigma2y, sigma2y);
fprintf('sigma2_w: Learned= %.4f \n', model.sigma2w);



%% Evaluate predictive distribution over fstar, and also gstar predictions
[mFpred, vFpred]  =  mteugpGetPredictive( model, xstar );
gpred             = mteugpPredict( model, mFpred, vFpred ); % 
plot_confidence_interval(xstar, mFpred, sqrt(vFpred), [], 1, 'b', [0.7 0.9 0.95]); 
hold on; 
plot(xstar, gpred, 'k--', 'LineWidth', 2); hold on;  
%
plot_data(X, Y, xstar, fstar, gstar); hold on;
legend({'Model std (f*)', 'Model mean(f*)', 'Model mean(g*)', 'ftrue', 'gtrue', ...
    'ytrain'}, 'Location', 'SouthEast');
title(upper(model.linearMethod));

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
plot(v, gstar(idx), 'g','LineWidth',2); hold on;
plot(x, y, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k'); % data
set(gca, 'FontSize', 14);
end





























