function mteugpTestSeismic( idxMethod, D, boolRealData, writeLog )
%MTEUGPTESTSEISMIC Summary of this function goes here
%   Detailed explanation goes here
global RESULTSDIR;
global DATASET;

RESULTSDIR = 'results';
DATASET = 'seismicData';

data  = mteugpLoadDataSeismic( boolRealData );
linearMethod  = {'Taylor', 'Unscented'};



runModel(data, linearMethod{idxMethod}, D, writeLog);
% [dopt, vopt, gpred] = runMAPBenchmark(data, boolRealData);
 

end



%% 
function runModel(data, linearMethod, D, writeLog)
global RESULTSDIR;
global DATASET;
RESULTSDIR = [RESULTSDIR, '/', DATASET, '/', 'D', num2str(D), '/', linearMethod];
system(['mkdir -p ', RESULTSDIR]);
if (writeLog)
    str = datestr(now, 30);
    diary([RESULTSDIR,  '/', str, '.log']);
end

model    = mteugpGetConfigSeismic(data, linearMethod, D);
model.X  = normalise(model.X);
model    = mteugpLearn( model); 

%% OK  I AM HERE
[ meanF, CovF ] = mteugpGetP( model, model.Q, model.Phi );
[depth, vel, std_d, std_v ] = mteugpUnwrapSeismicParameters( meanF, CovF );
plotWorldModel(data, depth, vel);

fname = [RESULTSDIR, '/', DATASET, '.mat'];
save(fname, 'model');
 
diary off;
 
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
plotTravelTimes(data.xtrain, data.ytrain, data.n_layers);
[dopt, vopt] = fsseRegSolution(data.ytrain', data.n_x, data.n_layers, data.doffsets, data.voffsets, realdata);
dopt = dopt';
vopt = vopt';
gpred = getFwdPredictions(dopt, vopt);

plotWorldModel(data, dopt, vopt);
plotPredictions(gpred, data.ytrain, data.n_layers);

end


%%
function Gpred = getFwdPredictions(dpred, vpred)
% dpred [n_x x n_layers]
F       = mteugpWrapSeismicParameters( dpred, vpred );
Gpred   = mteugpFwdSeismic(F, 0, 0);

end



%%
function plotPredictions(Gpred, Y, n_layers)
% plot forward predictions vs real observations
figure;

layercolor = 'rbgm';
hold on;
for layer = 1 : n_layers
    scatter(Y(:, layer), Gpred(:, layer), 10, layercolor(layer));
end
title('Real observations vs predicted observations')
ylabel('y')
xlabel('ysim')
end


    
function plotWorldModel(data, depth, vel)
% plot world model -- Depth
% depth (n_x x n_layers)
% vel   [nx x n_layers)

PlotWorldModelAlistair(data.xtrain', depth', vel', data.n_layers, data.d', data.v');

end

%%
function PlotWorldModelAlistair(x, fopt, vopt, n_layers, f, v)
figure;
plot([x(1), x(end)], [0, 0], 'k', 'linewidth', 3);
hold on;
for layer = 1 : n_layers
    plot(x, -fopt(layer, :), 'b', 'linewidth', 3);
    if (~isempty(f))
        plot(x, -f(layer, :), 'r--', 'linewidth', 3);
    end
end
title('Depth of boundaries')
xlabel('Sensor location (m)')
ylabel('Height (m)')
leg = {'Ground', 'Predicted boundaries'};
if ( ~isempty(v) )
    leg{end+1} = 'True Boundaies';
end
legend(leg);
    
    
% plot world model -- Velocity
figure;
hold on;
for layer = 1 : n_layers
    plot(x, vopt(layer, :), 'b', 'linewidth', 3);
    if ( ~isempty(v) )
    plot(x, v(layer, :), 'r--', 'linewidth', 3);
    end
end
title('Velocity of layers')
xlabel('Sensor location (m)')
ylabel('Velocity (m/s)')
leg = {'Predicted velocities'};
if ( ~isempty(v) )
    leg{end+1} = 'True velocities';
end
legend(leg);

end

function plotTravelTimes(x, y, n_layers)
% plot travel times
% x: (n_x x 1)
% y: (n_x x n_layers)
clf;
hold on;
for layer = 1 : n_layers
    plot(x, y(:, layer), 'g', 'linewidth', 3);
end
set(gca,'YDir','reverse');
title('Travel times');
xlabel('Sensor location (m)');
ylabel('Time (s)');
end




%% Original Function
function [dopt, vopt] = fsseRegSolution(y, n_x, n_layers, doffsets, voffsets, realdata)

if (~realdata)
    l_off = 1e-8;
    l_v = 0;
    l_d = 1e-7;
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
y_sim   = mteugpFwdSeismic(F, 0, 0)';

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
