function  model  = mteugpLearnAllSimplified( model )
%MTEUGPLEARNSIMPLIFIED mteugpLearn using simplified version of NELBO
%  and learning all the parameters jointly

model            = model.initFunc(model); 
nelbo_val       =  mteugpNelboSimplified( model ); 
mteugpShowProgress(0, nelbo_val);
model          = mteugpOptimizeAllSimplified(model);         
model          = mteugpUpdateCovariances(model);     


end







 