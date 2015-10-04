function [ fwdVal, J, errJ ] = egpEvalFwdModel( fwdFunc, f, boolJacob )
%EVALFWDMODEL Summary of this function goes here
%   Detailed explanation goes here
% Evaluates fwd model when using Extended GP
%
% boolJacob: Jacobian provided?
%
if (nargout == 1) % Check if gradients are required
    fwdVal = fwdfunc(f);  % simply computes the function
else
    %nout = nargout(fwdFunc); % FIX THIS -> Does not work for anonymous functions
    if ( boolJacob ) % functions provides Jacobian
        %fprintf('Using Jacobian provided by fwd function ...');
        [fwdVal, J] = fwdFunc(f);
        %fprintf('done\n');
    else % Estimates Jacobian numerically
        fwdVal      = fwdFunc(f); 
        %fprintf('Computing Jacobian numerically ... ');
        [J, errJ]   = jacobianest(fwdFunc, f);
        % fprintf('done\n');
     end
end

% Commented out 04/10/2015: FwdFunc should control 
% dimensions. This does not work for Q>1
%fwdVal  = fwdVal(:); % column vector


end


 