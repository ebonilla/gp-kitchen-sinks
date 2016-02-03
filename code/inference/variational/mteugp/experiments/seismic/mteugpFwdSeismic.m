% Forward model for seismic experiment
% G: the Observation model
% Edwin: Close over vel for now (see how we call NLOPT). But we do eventually
% want to also learn vel (though we may need a prior/regulariser).
% need to incorporate offset here
% dG: (P x Q)
function [Gval, dG] = mteugpFwdSeismic(F, doffsets, voffsets)
% D: [N X Q] 
% [1,.... Q] = [depth_layer_1, ..., depth_layer_nlayer, vel_layer_1, vel_layer_n_layer] 
n_layers = size(F,2)/2;
Depth    = F(:,1:n_layers);
Vel      = F(:,n_layers+1:end);
  
% accouting for prior offsets here 
Depth  = bsxfun(@plus, Depth, doffsets);
Vel    = bsxfun(@plus, Vel, voffsets); 

Gval    = G2(Depth, Vel); % EVB's function
%Gval   = G(Depth', Vel')'; % AR's function

if (nargout == 2) % gradients required
    dH = zeros(n_layers, n_layers); % wrt depth
    dV = zeros(n_layers, n_layers); % wrt vel
    
    % optimize?
    h   = [0, Depth(:,1:n_layers-1)];
    for k = 1 : n_layers
        for l = 1 : n_layers
            for i = 1 : l
                dH(l,k) = dH(l,k) + 2*( (i==k) - ((i-1) == k) )/Vel(:,i); % Vel here is 1 x n_layers
                dV(l,k) = dV(l,k) - 2*( (i==k)/Vel(:,i) ) * ( Depth(:,i) - h(:,i) )/Vel(:,i); 
            end
        end
    end
    dG = [dH, dV];    
end


end


%% Edwin's function
function g = G2(depth, vel)
% different signature to below, here is the tranpose
[N,Q] = size(depth);

T = 2*( depth(:,Q:-1:1) - [depth(:,Q-1:-1:1), zeros(N,1)] )./(vel(:,Q:-1:1));
g = cumsum ( fliplr(T), 2 ); 
     

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

