function perf = mteugpGetPerformanceBinaryClass(ytest, pred)
% Edwin V. Bonilla (http://ebonilla.github.io/)

perf.mnlp      = myMNLP( [], ytest, pred.gpred  );
perf.errorRate = myErrorRate([], ytest, pred.gpred );

end


