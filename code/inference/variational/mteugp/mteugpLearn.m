function  model  = mteugpLearn( model )
%MTEUGPLEARN Summary of this function goes here
%   Detailed explanation goes here

optConf = model.optConf;

model = mteugpInit(model); 
for i = 1 : optConf.globalIter
    
    model = mteugpOptimizeMeans(model);
    model = mteugpOptimizeCovariances(model);
    model = mteugpOptimizeFeatures(model); 

end

% After final update of features
model = mteugpOptimizeMeans(model);
model = mteugpOptimizeCovariances(model);




end










    














