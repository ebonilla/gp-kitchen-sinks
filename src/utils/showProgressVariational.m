function showProgressVariational(i, nelbo, err)
%
%SHOWPROGRESSVARIATIONAL % function show_progress(i, nelbo, err)
%   Detailed explanation goes here
% Edwin V. Bonilla (http://ebonilla.github.io/)

fprintf('Iteration %d : ', i-1);
fprintf(' [nelbo=%f] ', nelbo );
fprintf(' [error=%.6f]', err);

fprintf('\n');    

return;
 