% Forward model for seismic experiment
% G: the Observation model
% Edwin: Close over vel for now (see how we call NLOPT). But we do eventually
% want to also learn vel (though we may need a prior/regulariser).
% need to incorporate offset here
function Gval = mteugpFwdSeismic(F)
% D: [N X Q] 
% [1,.... Q] = [depth_layer_1, ..., depth_layer_nlayer, vel_layer_1, vel_layer_n_layer] 
n_layers = size(F,2)/2;
Depth    = F(:,1:n_layers);
Vel      = F(:,n_layers+1:end);
Gval     = G(Depth', Vel')';

end


%% Origina G function
function g = G(depth, vel)
% depth: (n_layers x n_x)
% vel : (n_layers x n_x)
%
n_layers = size(depth, 1);
n_x = size(depth,2);
g = zeros(n_layers, n_x);
for layer = 1 : n_layers
    if layer == 1
        g(layer, :) = 2*depth(layer, :)./vel(layer,:);
    else
        g(layer, :) = 2*(depth(layer,:)-depth(layer-1,:))./vel(layer, :) ...
                + g(layer-1, :);
    end
end
end 

