function theta = mteugpWrapSigma2w(sigma2w)
% We work on the log precison space
lambdaw = 1./sigma2w;
theta   = log(lambdaw);

end
