function perf = mteugpGetPerformanceMultiClass(ytest, pred)
% Edwin V. Bonilla (http://ebonilla.github.io/)

perf.mnlp      = myMNLPMulti( [], ytest, pred.gpred  );
perf.errorRate = myErrorRateMulti([], ytest, pred.gpred );

end

