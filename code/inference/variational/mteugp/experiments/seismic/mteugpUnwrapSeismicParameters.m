function [depth, vel, std_d, std_v ] = mteugpUnwrapSeismicParameters( F, covF )
%MTEUGPUNWRAPSEISMICPARAMETERS Summary of this function goes here
%   Detailed explanation goes here
% F is the latent functions: e.g. Phi*M
Q = size(F,2);
n_layers = Q/2;
depth = F(:, 1:n_layers);
vel   = F(:, n_layers:end);

if (nargin == 2) % returns the std deviations 
    std_d = zeros(size(depth));
    std_v  = zeros(size(vel));
    for j = 1 :n_layers
        std_d(:,j) = diag(covF(:,:,j));
    end
    for j = n_layers+1 : Q
        std_v(:,j) =  diag(covF(:,:,j));
    end
end


end

