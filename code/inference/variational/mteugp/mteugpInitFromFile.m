function [model, exitCode]  = mteugpInitFromFile( model )
%MTEUGPINITFROMFILE Summary of this function goes here
%   Detailed explanation goes here

exitCode = 0;
try
    m = load(model.resultsFname);
    fprintf('loading previous model from %s\n', model.resultsFname);
    % we copy one by one for backward compatibilty 
    fNames = fieldnames(m.model);
    for i = 1 : length(fNames)
        % do not copy optimization / configuration fields
        if ( isempty(strfind(fNames{i}, 'Conf')) && ...
            isempty(strfind(fNames{i}, 'Func')) ) 
            model.(fNames{i}) = m.model.(fNames{i});
        end
    end
    exitCode = 1;
    return;
catch ME
end


end

