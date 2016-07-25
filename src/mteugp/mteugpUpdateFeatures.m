function model = mteugpUpdateFeatures(model, theta)
model.featParam = theta;
model.Phi       = feval(model.featFunc, model.X, model.Z, model.featParam);
end


