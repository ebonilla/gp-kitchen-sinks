function thetaLB  = mteugpGetHyperLB( model  )
%MTEUGPGETHYPERLB Get Hyperparameter lower bounds
%   Detailed explanation goes here
% Edwin V. Bonilla (http://ebonilla.github.io/)

% Default lower bounds (-inf)
m.featParam = -Inf*ones(size(model.featParam));
m.sigma2y   =  zeros(size(model.sigma2y)); 
m.sigma2w   =  zeros(size(model.sigma2w));

    
if ( isfield(model, 'hyperLB') )
    fNames = fieldnames(model.hyperLB);
    for i = 1 : length(fNames)
        m.(fNames{i}) = model.hyperLB.(fNames{i});
    end 
end
thetaLB  = mteugpWrapHyper(m);    

end

  

