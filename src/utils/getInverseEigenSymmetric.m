function  invK  = getInverseEigenSymmetric( E, V )
%GETINVERSEEIGEN Summary of this function goes here
%   Gets the inverse based on the Eigen decomposition: E V E'
% E: Matrix of Eigen vector
% V: Matrix of Eigenvalues on the diagonal
% Edwin V. Bonilla (http://ebonilla.github.io/)

invK = E* diag(1./diag(V))*E';


end

