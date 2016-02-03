function data  = mteugpLoadDataSeismic( realData )
%MTEUGPLOADDATASEISMIC Summary of this function goes here
%   Detailed explanation goes here
if (~realData)
    [x, doffsets, voffsets, y, v, f] = simulateworld();
    data.xtrain   = x';
    data.ytrain   = y';
    data.doffsets =  doffsets;
    data.voffsets = voffsets;    
    data.d        = f'; % tue depths    
    data.v        = v'; % true velocities
else
    [x, doffsets, voffsets, y] = loaddata(4);
    data.xtrain   = x;
    data.ytrain   = y'; 
    data.doffsets =  doffsets;
    data.voffsets = voffsets;
    data.d        = [];     
    data.v        = [];
end
  
data.n_layers = length(voffsets);
data.n_x      = size(data.xtrain, 1);

end

%% Function to load actual seismic data
function [x, doffsets, voffsets, y] = loaddata(n_layers)
    SRCDIR = 'data/seismicData';
    if (n_layers < 2) || (n_layers > 4)
        error('Number of layers must be between 2 and 4 inclusive')
    end
    
    doffsets = [200, 500, 1600, 2200]; % Made up from a 'single-point' inversion
    x = load([SRCDIR, '/inversions/processed_sensorlocs.csv']);
    y = load([SRCDIR,'/inversions/processed_times.csv'])';
    voffsets = load([SRCDIR,'/inversions/processed_velocities.csv']);
    voffsets = voffsets(1, :);
    
    % filter number of layers
    y = y(1:n_layers, :);
    doffsets = doffsets(1:n_layers);
    voffsets = voffsets(1:n_layers);
    
end

%% Simulate a random world
function [x, doffsets, voffsets, y, v, f] = simulateworld()
% make a grid of x's
n_layers    = 2;
n_x         = 50;
n_spline    = 20;  % Knot points
width       = 3000;
layer_noise = [0.01, 0.015];  % noise on each layer
doffsets    = [700, 1300];  % prior depth offsets for each layer, m
layer_std   = 100; % Height standard deviation, m
voffsets    = [2000, 4000];  % velocity offsets of each layer, m/s
velgrads    = [0.01, 0.02];

% Generate a spline
x   = linspace(0, width, n_x);
sx  = linspace(0, width, n_spline);
sy  = layer_std * randn(n_layers, n_spline);
f   = geom_model(sx, sy, x, doffsets);
v   = vel_model(voffsets, velgrads, x);

% generate observations,
% Simulate some noisy y's by adding Gaussian observation noise:
F = mteugpWrapSeismicParameters(f', v');
g = mteugpFwdSeismic(F, 0, 0)'; 
y = zeros(n_layers, n_x);
for layer = 1 : n_layers
    y(layer, :) = g(layer, :) + randn(1, n_x)*layer_noise(layer);
end

end
 
%% Compute the layer heights / depths
function f = geom_model(sx, sy, x, doffsets)
n_layers = size(sy, 1);
n_x = numel(x);
f = zeros(n_layers, n_x);
for layer = 1:n_layers
    sy(layer, :) = sy(layer, :) + doffsets(layer);
    f(layer, :) = interp1(sx, sy(layer, :), x, 'spline');
    if (layer == 1)
        f(layer, :) = max(f(layer, :), 0);
    else
        f(layer, :) = max(f(layer, :), f(layer-1, :));
    end
end
end 



%% Compute the layer velocity functions
function v = vel_model(voffsets, vgrads, x)
    %v = bsxfun(@times, vgrads', x) + voffsets';
    v = bsxfun(@plus, bsxfun(@times, vgrads', [x; x]), voffsets');
end

















