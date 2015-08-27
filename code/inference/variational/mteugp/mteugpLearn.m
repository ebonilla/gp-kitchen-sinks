function  model  = mteugpLearn( model, optconf )
%MTEUGPLEARN Summary of this function goes here
%   Detailed explanation goes here



model = mteugpInit(model); 
for i = 1 : optconf.globalIter
    
    model = mteugpOptimizeMeans(model, optconf);
    model = mteugpOptimizeCovariances(model);
    model = mteugpOptimizeFeatures(model, optconf); 

end





end










    














