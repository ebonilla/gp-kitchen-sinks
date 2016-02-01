% Very simple seismic inversion simulation.
% make sure the NLopt package is available
%addpath("/usr/share/octave/packages/NLopt-2.4.2/")

% NOTE!!!
% In this script we assume we KNOW the velocities of each layer. Realistically
% this is not the case and this is also something we need to learn.
% Unfortunatly this is an ill-posed problem, there are an infinite set of
% velocities that can fit the observations, but will change the offsets of the 
% layers.

%%  
function testSeismicDan()
    % Choose whether to run simulation or operate on real data
    realdata = false;
    
    if ~realdata    
        [x, doffsets, voffsets, y, v, f] = simulateworld();
    else
        [x, doffsets, voffsets, y] = loaddata(2);
    end
      
    n_layers = length(voffsets);
    n_x = length(x);
    
    % SSE solver settings (regularisers)
    if ~realdata 
        l_off = 1e-8;
        l_v = 0;
        l_d = 1e-7;
    else
        l_off = 0;
        l_v = 1e-5;
        l_d = 1e-5;
    end
    
    % Optimise f for a solution:
    opt.xtol_rel = 1e-8;
    opt.ftol_rel = 1e-7;
    opt.maxeval = 50000;
    % TODO: [EVB] Change back above value 
    %opt.maxeval = 500;
    
    opt.algorithm = NLOPT_LN_BOBYQA;
    f0 = [bsxfun(@plus, zeros(n_layers, n_x) , doffsets');
          bsxfun(@plus, zeros(n_layers, n_x) , voffsets')];
    f0 = f0(:)';
    f_shape = [n_layers, n_x];
    opt.min_objective = @(z) llh(reshape(z(1:prod(f_shape)), f_shape), ...
                                 reshape(z(prod(f_shape)+1:end), f_shape), ... 
                                 y, doffsets, l_off, l_d, l_v);
    opt.lower_bounds = zeros(1, 2 * prod(f_shape)) + 1e-5;
    [ores, fmin, retcode] = nlopt_optimize(opt, f0);
    retcode
    fopt = reshape(ores(1:prod(f_shape)), f_shape);
    vopt = reshape(ores(prod(f_shape)+1:end), f_shape);
    
    % plot travel times
    clf;
    hold on;
    for layer = 1 : n_layers
        plot(x, y(layer, :), 'g', 'linewidth', 3);
    end
    set(gca,'YDir','reverse');
    title('Travel times')
    xlabel('Sensor location (m)')
    ylabel('Time (s)')
    
    % plot world model -- Depth
    figure;
    plot([x(1), x(end)], [0, 0], 'k', 'linewidth', 3);
    hold on;
    for layer = 1 : n_layers
        plot(x, -fopt(layer, :), 'b', 'linewidth', 3);
        if (~realdata)
            plot(x, -f(layer, :), 'r--', 'linewidth', 3);
        end
    end
    title('Depth of boundaries')
    xlabel('Sensor location (m)')
    ylabel('Height (m)')
    leg = {'Ground', 'Predicted boundaries'};
    if ~realdata
        leg{end+1} = 'True Boundaies';
    end
    legend(leg);
    
    
    % plot world model -- Velocity
    figure;
    hold on;
    for layer = 1 : n_layers
        plot(x, vopt(layer, :), 'b', 'linewidth', 3);
        if ~realdata
            plot(x, v(layer, :), 'r--', 'linewidth', 3);
        end
    end
    title('Velocity of layers')
    xlabel('Sensor location (m)')
    ylabel('Velocity (m/s)')
    leg = {'Predicted velocities'};
    if ~realdata
        leg{end+1} = 'True velocities';
    end
    legend(leg);
    
    % plot forward predictions vs real observations
    if ~realdata
        layercolor = {'r', 'b'};
        ysim = G(fopt, v);
        figure;
        hold on;
        for layer = 1 : n_layers
          scatter(y(layer, :), ysim(layer, :), 10, layercolor{layer});
        end
        title('Real observations vs predicted observations')
        ylabel('y')
        xlabel('ysim')
    end
end

% Simulate a random world
function [x, doffsets, voffsets, y, v, f] = simulateworld()
    
    % make a grid of x's
    n_x = 50;
    width = 3000;
    x = linspace(0, width, n_x);
    
    % Some simulation settings
    n_layers = 2;
    layer_noise = [0.01, 0.015];  % noise on each layer
    layer_std = 100;
    doffsets = [700, 1300];  % prior depth offsets for each layer, m
    voffsets = [2000, 4000];  % velocity offsets of each layer, m/s
    velgrads = [0.01, 0.02];

    % Generate a spline
    n_spline = 20;  % Knot points
    sx = linspace(0, width, n_spline);
    sy = layer_std * randn(n_layers, n_spline);
    f = geom_model(sx, sy, x, doffsets);
    v = vel_model(voffsets, velgrads, x);

    % generate observations
    g = G(f, v);
    
    % Simulate some noisy y's by adding Gaussian observation noise:
    for layer=1:n_layers
        y(layer, :) = g(layer, :) + randn(1, n_x)*layer_noise(layer);
    end

end


% Function to load actual seismic data
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

% define an un-normalised log likelhood function that will be optimized!
% This is just a SSE objective so will try to fit the *noisy* observations
% exactly!
function obj = llh(f, v, y, doffsets, l_off, l_d, l_v)
    y_sim = G(f, v);
    sse = sum(sum( (y - y_sim).^2 ));
    regoff = sum(sum( (bsxfun(@minus, f,  doffsets')).^2 ));
    regdvar = sum(sum( abs(f(:, 1:end-1) - f(:, 2:end)) ));
    regvvar = sum(sum( abs(v(:, 1:end-1) - v(:, 2:end)) ));
    obj = sse + l_off*regoff + l_d*regdvar + l_v*regvvar;
    fprintf('Objective: %f\n', obj);
    %fflush(stdout); 
end


% Compute the layer heights
function f = geom_model(sx, sy, x, doffsets)
    n_layers = size(sy, 1);
    n_x = numel(x);
    f = zeros(n_layers, n_x);
    for layer=1:n_layers
        sy(layer, :) = sy(layer, :) + doffsets(layer);
        f(layer, :) = interp1(sx, sy(layer, :), x, 'spline');
        if layer==1
            f(layer, :) = max(f(layer, :), 0);
        else
            f(layer, :) = max(f(layer, :), f(layer-1, :));
        end
    end
end 

% Compute the layer velocity functions
function v = vel_model(voffsets, vgrads, x)
    %v = bsxfun(@times, vgrads', x) + voffsets';
    v = bsxfun(@plus, bsxfun(@times, vgrads', [x; x]), voffsets');
end


% G: the Observation model
% Edwin: Close over vel for now (see how we call NLOPT). But we do eventually
% want to also learn vel (though we may need a prior/regulariser).
function g = G(f, vel)
    n_layers = size(f, 1);
    n_x = size(f,2);
    g = zeros(n_layers, n_x);
    for layer = 1 : n_layers
        if layer == 1
            g(layer, :) = 2*f(layer, :)./vel(layer,:);
        else
            g(layer, :) = 2*(f(layer,:)-f(layer-1,:))./vel(layer, :) ...
                + g(layer-1, :);
        end
    end
end












