function thetaLB  = mteugpGetHyperUB( model  )
%MTEUGPGETHYPERUB Get Hyperparameter upper bounds
%   Detailed explanation goes here
m.featParam = Inf*ones(size(model.featParam));
m.sigma2y   = Inf*ones(size(model.sigma2y)); 
m.sigma2w   = Inf*ones(size(model.sigma2w));

 
theta   = mteugpWrapHyper( model );
thetaLB = -Inf*ones(size(theta)); 

    
if ( isfield(model, 'hyperUB') )
    fNames = fieldnames(model.hyperUB);
    for i = 1 : length(fNames)
        m.(fNames{i}) = model.hyperUB.(fNames{i});
    end 
    thetaLB  = mteugpWrapHyper(m);    
end



end


