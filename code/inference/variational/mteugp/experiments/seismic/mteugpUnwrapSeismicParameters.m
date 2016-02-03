function [depth, vel, std_d, std_v ] = mteugpUnwrapSeismicParameters( model, F, varF )
%MTEUGPUNWRAPSEISMICPARAMETERS Summary of this function goes here
%   Detailed explanation goes here
% F is the latent functions: e.g. Phi*M
Q = size(F,2);
n_layers = Q/2;
idx_d = 1:n_layers;
idx_v = n_layers+1:Q;
depth = F(:,idx_d);
vel   = F(:,idx_v );
std_d = sqrt(varF(:, idx_d));
std_v = sqrt(varF(:, idx_v));

% accouting for offsets here 
depth  = bsxfun(@plus, depth, model.priorDepth);
vel    = bsxfun(@plus, vel, model.priorVel);


% if (nargin == 2) % returns the std deviations 
%     std_d = zeros(size(depth));
%     std_v  = zeros(size(vel));
%     for j = 1 :n_layers
%         std_d(:,j) = diag(covF(:,:,j));
%     end
%     for j = n_layers+1 : Q
%         std_v(:,j) =  diag(covF(:,:,j));
%     end
% end


end
 
  