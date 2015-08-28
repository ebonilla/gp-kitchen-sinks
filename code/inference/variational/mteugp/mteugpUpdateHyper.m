function  model  = mteugpUpdateHyper( model, theta )
%MTEUGPUPDATEHYPER Summary of this function goes here
%   Update model given the hyper-parameters

L          = length(theta);
P          = model.P; % Number of tasks
D          = model.D;  % Dimensionality of new feature space
nFeatParam = L - P - 1; % Number of feature parameters
theta_phi  = theta(1:nFeatParam);
theta_y    = theta(nFeatParam + 1 : nFeatParam + P);
theta_w    = theta(nFeatParam + P + 1 : L); % should be 1-d :-)

% Updating corresponding structures
model.featParam = theta_phi;
model.Phi       = feval(model.featFunc, model.X, theta_phi); 
model.sigma2y   = exp(theta_y);
model.sigma2w   = exp(theta_w)*ones(D,1);


end

