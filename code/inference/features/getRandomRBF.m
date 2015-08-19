function PHI = getRandomRBF(x, Z, sigma_z)
D = size(Z,1); % dimensionality of new fatures (# bases)
Z = sigma_z*Z;
% Get random RBF Features
% Both settings actually work with the corresponding 
% definition of optimal sigma
PHI     = (1/sqrt(D))*[cos(2*pi*x*Z'), sin(2*pi*x*Z')]; % 
%PHI     = (1/sqrt(D))*[cos(x*Z'), sin(x*Z')]; 

return;


  