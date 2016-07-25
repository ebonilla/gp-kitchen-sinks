function mteugpTestSeismic( idxMethod, D, boolRealData, writeLog )
%MTEUGPTESTSEISMIC Summary of this function goes here
%   Detailed explanation goes here
global RESULTSDIR;
global DATASET;
global LOADFROMFILE;
global TRGFIGDIR;
global SAVEPLOTS;
global SAVERESULTS;

TRGFIGDIR       = 'tex/icml2016/figures';
RESULTSDIR      = 'results';
DATASET         = 'seismicData';
LOADFROMFILE    = 1;
SAVEPLOTS       = 1;
SAVERESULTS     = 0;

if (~boolRealData)
    DATASET = [DATASET, 'Toy'];
end

data  = mteugpLoadDataSeismic( boolRealData );
linearMethod  = {'Taylor', 'Unscented'};



runModel(data, linearMethod{idxMethod}, D, writeLog);
%[dopt, vopt, gpred] = runMAPBenchmark(data, boolRealData);
  

end
 


%% 
function runModel(data, linearMethod, D, writeLog)
global RESULTSDIR;
global DATASET;
global LOADFROMFILE;
global TRGFIGDIR;
global SAVEPLOTS;
global SAVERESULTS;


RESULTSDIR = [RESULTSDIR, '/', DATASET, '/', 'D', num2str(D), '/', linearMethod];
fname  = [RESULTSDIR, '/', DATASET, '.mat'];
if (LOADFROMFILE)
    load(fname);
else
    system(['mkdir -p ', RESULTSDIR]);
    if (writeLog)
        str = datestr(now, 30);
        diary([RESULTSDIR,  '/', str, '.log']);
    end
    model             = mteugpGetConfigSeismic(data, linearMethod, D);
    model.resultsFname = fname;
    
    % model.X  = normalise(model.X); 
 
    % learning modell parameters
    model           = mteugpLearn( model); 

    if (SAVERESULTS)
        save(fname, 'model');
    end
    diary off;
end
 
% testJacobian(model);

[ meanF, varF ] = mteugpGetPredictive( model, model.X);

[depth, vel, std_d, std_v ] = mteugpUnwrapSeismicParameters(meanF, varF );
Gpred = mteugpGetFwdPredictionsSeismic(depth, vel);

predModel.meanH = depth';
predModel.meanV = vel';
predModel.stdH  = std_d';
predModel.stdV  = std_v';

save(fname, 'model', 'meanF', 'varF', 'depth', 'vel', 'std_d', 'std_v', 'Gpred');

% loading MCMC result 
load('results/seismicData/mcmcSamples_new.mat', 'draws_f', 'draws_v');
mcmc.meanH = reshape(mean(draws_f, 1)', data.n_x, data.n_layers)';
mcmc.meanV = reshape(mean(draws_v, 1)', data.n_x, data.n_layers)';
mcmc.stdH = reshape(std(draws_f, 0, 1)', data.n_x, data.n_layers)';
mcmc.stdV = reshape(std(draws_v, 0, 1)', data.n_x, data.n_layers)';

save('all_results_seismic.mat', 'predModel', 'mcmc', 'data', 'depth', 'vel', 'data'); 

t_handle = mteugpPlotTravelTimesSeismic(data.xtrain, data.ytrain, data.n_layers);
[d_handle, v_handle] =  mteugpPlotWorldSeismic(data, depth, vel, std_d, std_v, mcmc ); 
pred_handle = mteugpPlotPredictionsSeismic(Gpred, model.Y, data.n_layers);


% differences in variance: variational vs MCMC
% err_std = (std_d - mcmc.stdH')./mcmc.meanH';
% figure; hist(err_std(:));
% min(err_std(:))
% max(err_std(:))
 


if (SAVEPLOTS)
    fname = [TRGFIGDIR, '/', DATASET, '-travel-times', '-', num2str(D)];
    saveSinglePlot(t_handle, fname);
    %
    fname = [TRGFIGDIR, '/', DATASET, '-depth-', linearMethod, '-', num2str(D)];
    saveSinglePlot(d_handle, fname);    
    %
    fname = [TRGFIGDIR, '/', DATASET, '-vel-', linearMethod, '-', num2str(D)];
    saveSinglePlot(v_handle, fname);        
    %
    fname = [TRGFIGDIR, '/', DATASET, '-pred-', linearMethod, '-', num2str(D)];
    saveSinglePlot(pred_handle, fname);       
end

end


function saveSinglePlot(fig_handle, fname)
fname = strrep(fname, ' ', '-');
saveas(fig_handle, [fname, '.eps'], 'epsc' );
saveas(fig_handle, [fname, '.png'], 'png' );
system(['epstopdf ', fname, '.eps']);
end

%% Test Jacobian of fwd model
function testJacobian(model)
fobj = @(theta) fwdWrapper(theta, model);
for i = 1 : 10
    f    = 100*rand(1, model.Q);
    gradNum = jacobianest(fobj, f);
    [Gval, grad] = model.fwdFunc(f);
    delta = abs(gradNum(:) - grad(:));
    max(delta)
end
end


%% 
function G = fwdWrapper(theta, model)
n_layers = size(theta,2)/2;
d        = theta(:,1:n_layers);
v        = theta(:,n_layers+1:end);
Depth    = reshape(d, 1, n_layers);
V        = reshape(v, 1, n_layers);
F        = [Depth, V];
G        = model.fwdFunc(F);
end

%% 
function [dopt, vopt, gpred] = runMAPBenchmark(data, realdata)
mteugpPlotTravelTimesSeismic(data.xtrain, data.ytrain, data.n_layers);
[dopt, vopt] = fsseRegSolution(data.ytrain', data.n_x, data.n_layers, data.doffsets, data.voffsets, realdata);
dopt = dopt';
vopt = vopt';
gpred = mteugpGetFwdPredictionsSeismic(dopt, vopt);

mteugpPlotWorldSeismic(data, dopt, vopt);
mteugpPlotPredictionsSeismic(gpred, data.ytrain, data.n_layers);

end


 






%% Original Function
function [dopt, vopt] = fsseRegSolution(y, n_x, n_layers, doffsets, voffsets, realdata)

if (~realdata)
    l_off = 0;
    l_v = 0;
    l_d = 0;
% TODO: [EVB] Uncomment me below    
%    l_off = 1e-8;
%    l_v = 0;
%    l_d = 1e-7;
else
    l_off = 0;
    l_v = 1e-5;
    l_d = 1e-5;
 end

% Optimization with NLPOY
height0 = bsxfun(@plus, zeros(n_layers, n_x) , doffsets');
L = n_layers*n_x;
vel0    = bsxfun(@plus, zeros(n_layers, n_x) , voffsets');
f0 = [height0(:); vel0(:)];
fobj = @(theta) llh(theta, y, doffsets, l_off, l_d, l_v, n_layers, n_x);
%      opt.lower_bounds = zeros(1, 2 * prod(f_shape)) + 1e-5;
%      opt.min_objective = fobj;    
%     opt.xtol_rel = 1e-8;
%     opt.ftol_rel = 1e-7;
%     opt.maxeval = 50000;    
%     opt.algorithm = NLOPT_LN_BOBYQA;

%     [ores, fmin, retcode] = nlopt_optimize(opt, f0);
%     retcode
    
 % Optimization with Matlab's optimizer
options = optimoptions('fminunc','Algorithm','quasi-newton');
options.MaxIter = 10000;  
[ores, fminVal, retcode ] = fminunc(fobj, f0, options);
retcode

dopt = reshape(ores(1 : L), n_layers, n_x);
vopt = reshape(ores(L+1:end), n_layers, n_x);
    
    
 
end

 

% define an un-normalised log likelhood function that will be optimized!
% This is just a SSE objective so will try to fit the *noisy* observations
% exactly!
function obj = llh(theta, y, doffsets, l_off, l_d, l_v, n_layers, n_x)
L       = n_layers * n_x;
depth   = reshape(theta(1:L), n_layers, n_x);
vel       = reshape(theta(L+1:end), n_layers, n_x);

F       = mteugpWrapSeismicParameters( depth', vel' );
y_sim   = mteugpFwdSeismic(F)';

% Data fit
sse     = sum(sum( (y - y_sim).^2 ));

% REgular
regoff  = sum(sum( (bsxfun(@minus, depth,  doffsets')).^2 ));
regdvar = sum(sum( abs(depth(:, 1:end-1) - depth(:, 2:end)) ));
regvvar = sum(sum( abs(vel(:, 1:end-1) - vel(:, 2:end)) ));
obj     = sse + l_off*regoff + l_d*regdvar + l_v*regvvar;
fprintf('Objective: %f\n', obj);
    %fflush(stdout); 
end



function  val = smll(muTrue, varTrue, muPred, varPred )
%MYSMLL Standardised mean log loss
%   ean Negative log likelihood aussuming gaussianity
%   and standardised by using a gaussian with the training data stats

ll_model = - logOfGaussUnivariate( ytest, muPred, varPred );
ll_naive = - logOfGaussUnivariate( ytest, muTrue, varTrue );

val = mean(ll_model - ll_naive,1);

end








