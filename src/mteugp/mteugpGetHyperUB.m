function thetaUB  = mteugpGetHyperUB( model  )
%MTEUGPGETHYPERUB Get Hyperparameter upper bounds
%   Detailed explanation goes here
% Edwin V. Bonilla (http://ebonilla.github.io/)

m.featParam = Inf*ones(size(model.featParam));
m.sigma2y   = Inf*ones(size(model.sigma2y)); 
m.sigma2w   = Inf*ones(size(model.sigma2w));

if ( isfield(model, 'hyperUB') )
    fNames = fieldnames(model.hyperUB);
    for i = 1 : length(fNames)
        m.(fNames{i}) = model.hyperUB.(fNames{i});
    end 
end

thetaUB  = mteugpWrapHyper(m);    



end


   