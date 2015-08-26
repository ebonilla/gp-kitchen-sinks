function  theta  = initRandomRBF(  )
%INITRANDOMRBF Initializes parameters of random RBF
%   Detailed explanation goes here
sigma_z = rand;

% sigma_z = exp(theta) 
theta = log(sigma_z);

end

