function  val  = isDiag( K )
%ISDIAG Test if matrix K is diagonal
% Edwin V. Bonilla (http://ebonilla.github.io/)

val =  sum(sum(K - diag(diag(K)))) == 0;



return;

