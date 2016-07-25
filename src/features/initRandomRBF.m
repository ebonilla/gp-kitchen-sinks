function  theta  = initRandomRBF(sigmaf )
%INITRANDOMRBF Initializes parameters of random RBF
%   Detailed explanation goes here
 
if(nargin == 0) 
    sigmaf = 1;
end

sigma_z = getOptimalSigmaz(sigmaf);
%sigma_z = rand;
% DELETE ME
% sigma_z = 10;


theta = log(sigma_z); % exponential mapping
%theta = sqrt(sigma_z); % quadratic mapping 

end

