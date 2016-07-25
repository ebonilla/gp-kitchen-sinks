function perf = mteugpGetPerformanceBinaryClass(ytest, pred)
perf.mnlp      = myMNLP( [], ytest, pred.gpred  );
perf.errorRate = myErrorRate([], ytest, pred.gpred );

end


