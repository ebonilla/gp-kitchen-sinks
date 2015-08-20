function [Phi, GradPhi] = getRandomRBF(x, Z, theta)
sigma_z = theta;

D = size(Z,1); % dimensionality of new fatures (# bases)

W    = 2*pi*x*Z';
Phi   = (1/sqrt(D))*[cos(sigma_z*W), sin(sigma_z*W)]; % 

if (nargout == 2) % Gradients are required
    GradPhi =  (1/sqrt(D))*[-sin(sigma_z*W).*W, cos(sigma_z*W).*W]; 
end

end



%% old version
function PHI = getRandomRBF_old(x, Z, sigma_z)
D = size(Z,1); % dimensionality of new fatures (# bases)
Z = sigma_z*Z;
% Get random RBF Features
% Both settings actually work with the corresponding 
% definition of optimal sigma
PHI     = (1/sqrt(D))*[cos(2*pi*x*Z'), sin(2*pi*x*Z')]; % 
%PHI     = (1/sqrt(D))*[cos(x*Z'), sin(x*Z')]; 

end
