function theta = mteugpWrapSigma2y(sigma2y)
% We work on the log precison space
lambday = 1./sigma2y;
theta   = log(lambday);

end

