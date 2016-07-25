function set_equal_axes()
% Edwin V. Bonilla (http://ebonilla.github.io/)

aa   = axis();
mini = min([aa(1) aa(3)]); 
maxi = max([aa(2) aa(4)]);
axis([mini maxi mini maxi]);




return;
