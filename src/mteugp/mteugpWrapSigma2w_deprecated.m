function theta = mteugpWrapSigma2w_deprecated(sigma2w)
% We work on the log precison space
% Edwin V. Bonilla (http://ebonilla.github.io/)

lambdaw = 1./sigma2w;
theta   = log(lambdaw);

end
 