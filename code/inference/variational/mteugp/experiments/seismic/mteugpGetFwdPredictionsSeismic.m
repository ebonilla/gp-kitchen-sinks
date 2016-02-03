function Gpred = mteugpGetFwdPredictionsSeismic(dpred, vpred)
% dpred [n_x x n_layers]
F       = mteugpWrapSeismicParameters( dpred, vpred );
Gpred   = mteugpFwdSeismic(F, 0, 0);

end



      