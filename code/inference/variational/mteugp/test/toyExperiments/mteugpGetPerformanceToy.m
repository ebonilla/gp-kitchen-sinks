function perf  = mteugpGetPerformanceToy( pred, ftest, gtest )
%MTEUGPGETPERFORMANCETOY Get performance measures for toy expts
%   Detailed explanation goes here
% Pred: prediction structure
% ftest: True latent function f*
% gtest: g(f*)

perf.smseFstar  = mySMSE([], ftest, pred.mFpred );
perf.nlpdFstar  = myMLL( [], ftest,  pred.mFpred , pred.vFpred );
perf.smseGstar  = mySMSE([], gtest, pred.gpred );


end



