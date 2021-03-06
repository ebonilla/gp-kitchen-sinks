function [Phi, GradPhi] = getRandomRBF(x, Z, theta)

% if (nargin == 0) % return number of parameters
%     Phi = 1;
%     return;
% end
% sigma_z is the std deviation of the features
% Edwin V. Bonilla (http://ebonilla.github.io/)


sigma_z = exp(theta); % exponential mapping
%sigma_z = theta.^2;  % quadratic mapping
%sigma_z = theta;     % linear mapping

D = size(Z,1); % dimensionality of new fatures (# bases)

W    = 2*pi*x*Z';
Phi   = (1/sqrt(D))*[cos(sigma_z*W), sin(sigma_z*W)]; % 

if (nargout == 2) % Gradients are required
    GradPhi =  (1/sqrt(D))*[-sin(sigma_z*W).*W, cos(sigma_z*W).*W]; 
    
    GradPhi = GradPhi*sigma_z; % exponential mapping
    %GradPhi = 2*GradPhi*theta; % quadratic mapping
    
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
