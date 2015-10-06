function thetaLB  = mteugpGetHyperLB( model  )
%MTEUGPSETHYPERLB Get Hyperparameter lower bounds
%   Detailed explanation goes here
m.featParam = -Inf*ones(size(model.featParam));
m.sigma2y   =  zeros(size(model.sigma2y)); 
m.sigma2w   =  zeros(size(model.sigma2w));

 
theta   = mteugpWrapHyper( model );
thetaLB = -Inf*ones(size(theta)); 

    
if ( isfield(model, 'hyperLB') )
    fNames = fieldnames(model.hyperLB);
    for i = 1 : length(fNames)
        m.(fNames{i}) = model.hyperLB.(fNames{i});
    end 
    thetaLB  = mteugpWrapHyper(m);    
end



end


