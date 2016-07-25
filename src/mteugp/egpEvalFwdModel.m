function [ fwdVal, J, H ] = egpEvalFwdModel( fwdFunc, f, P, boolJacob, boolDiagHess)
%EVALFWDMODEL Summary of this function goes here
%   Detailed explanation goes here
% Evaluates fwd model when using Extended GP
%
% boolJacob: Jacobian provided?
% fwdFunc: R^Q --> R^P forward model function
% H: PxQ matrix of second derivatives
% Edwin V. Bonilla (http://ebonilla.github.io/)

if (nargout == 1) % Check if gradients are required
    fwdVal = fwdfunc(f);  % simply computes the function
    return;
end

if (nargout == 2) % Only jacobian is requested
    if ( boolJacob ) % functions provides Jacobian     %fprintf('Using Jacobian provided by fwd function ...');
     [fwdVal, J] = fwdFunc(f);
    else
      fwdVal      = fwdFunc(f); 
      J           = jacobianest(fwdFunc, f);
    end
    return;
end

% We get here if gradients are required
if (boolDiagHess) % If matrix of second derivatives if provided (d^2g_i/df_j^2) 
    [fwdVal, J, H] = fwdFunc(f);
    return;
end

% TODO: TEST THIS CODE :-)
% Only jacobian is provided, estimate second derivatives numerically
 if ( boolJacob ) % functions provides Jacobian     %fprintf('Using Jacobian provided by fwd function ...');
     [fwdVal, J] = fwdFunc(f);
     H = getDiagHess(fwdFunc, f, P);
     return;
 end
 
% if neither is provided: Estimate both nummericallly 
fwdVal      = fwdFunc(f); 
J           = jacobianest(fwdFunc, f);
H           = getDiagHess(fwdFunc, f, P);


% Commented out 04/10/2015: FwdFunc should control 
% dimensions. This does not work for Q>1
%fwdVal  = fwdVal(:); % column vector


end


function getDiagHess(fwdFunc, f, P)
Q       = size(f,2);
H       = zeros(P,Q);
for p = 1 : P         
    ptrFunc = @(ff) getSingleOutput(fwdFunc, ff, p);
    H(p,:)  = hessdiag(ptrFunc, f);
end
end



function g = getSingleOutput(fwdFunc, f, p)
fwdVal      = fwdFunc(f); 
g = fwdVal(:,p);

end

 