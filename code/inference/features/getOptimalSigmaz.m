function sigma_z = getOptimalSigmaz(ell)
% get optimal sigmaz based on the true length scale of the Gaussian process
% for random RBF
% INPUT:
%   - ell: The true length of the process
%
% both settings actually work with the corresponding definition
% of features
sigma_z = 1/(2*pi*ell); % exact setting from Fourier transfrom
%sigma_z = 1/ell; % exact setting from Fourier transfrom

return;
   