function [model, exitCode]  = mteugpInitFromFile( model )
%MTEUGPINITFROMFILE Summary of this function goes here
%   Detailed explanation goes here
% Edwin V. Bonilla (http://ebonilla.github.io/)

exitCode = 0;
try
    m = load(model.resultsFname);
    % we copy one by one for backward compatibilty 
%    fNames = fieldnames(m.model);
%     for i = 1 : length(fNames)
%         % do not copy optimization / configuration fields
%         if ( isempty(strfind(fNames{i}, 'Conf')) && ...
%             isempty(strfind(fNames{i}, 'Func')) ) 
%             model.(fNames{i}) = m.model.(fNames{i});
%         end
%     end
    model.Z         =  m.model.Z;
    model.sigma2y   =  m.model.sigma2y;   % likelihood variances
    model.sigma2w   =  m.model.sigma2w;  % hyper-parameters (of prior on w)
    model.M         =  m.model.M;
    model.featParam =  m.model.featParam;
    model.C         =  m.model.C;
    model.Phi       = feval(model.featFunc, model.X, model.Z, model.featParam); 
    model.D         = size(model.Phi,2); % actual number of features    
    [model.A, model.B] = mteugpUpdateLinearization(model); % lineariz. parameters
    model              = mteugpOptimizeCovariances( model );    
    model.nelbo     =  m.model.nelbo;

    fprintf('Parameters loaded from previous model at %s\n', model.resultsFname);
    exitCode = 1;
    return;
catch ME
end


end

