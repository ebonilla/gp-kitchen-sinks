function perf = mteugpGetPerformanceMultiClass(ytest, pred)
perf.mnlp      = myMNLPMulti( [], ytest, pred.gpred  );
perf.errorRate = myErrorRateMulti([], ytest, pred.gpred );

end

