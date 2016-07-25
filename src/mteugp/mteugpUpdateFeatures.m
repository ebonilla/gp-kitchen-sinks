function model = mteugpUpdateFeatures(model, theta)
% Edwin V. Bonilla (http://ebonilla.github.io/)

model.featParam = theta;
model.Phi       = feval(model.featFunc, model.X, model.Z, model.featParam);
end


