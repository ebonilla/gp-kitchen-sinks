function [ fwdVal, J, errJ ] = egpEvalFwdModel( fwdFunc, f )
%EVALFWDMODEL Summary of this function goes here
%   Detailed explanation goes here
% Evaluates fwd model when using Extended GP
%
if (nargout == 1) % Check if gradients are required
    fwdVal = feval(fwdfunc, f);  % simply computes the function
else
    nout = nargout(fwdFunc); % FIX THIS
    if (nout > 1) % functions provides Jacobian
        fprintf('Using Jacobian provided by fwd function ...');
        [fwdVal, J] = feval(fwdFunc, f);
    else % Estimates Jacobian numerically
        fwdVal      = feval(fwdFunc, f); 
        fprintf('Computing Jacobian numerically ... ');
        [J, errJ]   = jacobianest(fwdFunc, f);
        fprintf('done\n');
%     end
end
fwdVal  = fwdVal(:); % column vector    


end


