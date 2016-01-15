function  theta  = initRandomRBF(  )
%INITRANDOMRBF Initializes parameters of random RBF
%   Detailed explanation goes here

sigma_z = getOptimalSigmaz(1);
%sigma_z = rand;
% DELETE ME
% sigma_z = 10;


theta = log(sigma_z); % exponential mapping
%theta = sqrt(sigma_z); % quadratic mapping 

end

