function x = solveLinChol( L, y )
%SOLVELINCHOL Solves linear sytem Ax = y using chol decom of A
%   Detailed explanation goes here
% L: Lower triangular chol
% Edwin V. Bonilla (http://ebonilla.github.io/)


x = solve_chol(L',y);

return;

