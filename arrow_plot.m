% Fucntion to plot lines with arrows.
% Specify: arrow_plot(theta,len,col,plot_vars) where the arrow angle is 2*theta,
% the colour is col and the length is len.

% twnh May 99

function arrow_plot(theta,len,col,varargin) ;

% Plot line
plot(varargin{:}) ;

% Get last 2 points in line
x = varargin{1} ;
y = varargin{2} ;
no_pts = length(x) ;
x = x([no_pts-1:no_pts]) ;
y = y([no_pts-1:no_pts]) ;


% Get aspect ratio and limits of figure
tmp = get(gca,'PlotBoxAspectRatio') ;
asrat = tmp(1) ;
tmp = get(gca,'XLim') ;
xmin = tmp(1) ;
xmax = tmp(2) ;
tmp = get(gca,'YLim') ;
ymin = tmp(1) ;
ymax = tmp(2) ;

% Define mappings
xtoX    = [1/(xmax-xmin) 0 ; 0 1/(asrat*(ymax-ymin))] ;
xtoXoff = [xmin/(xmax-xmin); ymin/(ymax-ymin)] ;

% Convert to pixel coordinates
tmp = xtoX*[x(1); y(1)] + xtoXoff ;
X1 = tmp(1) ;
Y1 = tmp(2) ;

tmp = xtoX*[x(2); y(2)] + xtoXoff ;
X2 = tmp(1) ;
Y2 = tmp(2) ;

% Get gradient
alpha = atan2(Y2-Y1,X2-X1) ;

% Find positions of arrow tail
theta = theta*pi/180 ;
ptC = [X2-len*cos(alpha-theta); Y2-len*sin(alpha-theta)] ;
ptD = [X2-len*cos(alpha+theta); Y2-len*sin(alpha+theta)] ;

% Convert back to real coordinates
ptc = inv(xtoX)*(ptC+xtoXoff) ;
ptd = inv(xtoX)*(ptD+xtoXoff) ;

% Plot arrow patch
patch_temp = [x(2),y(2);ptc';ptd'] ;
patch(patch_temp(:,1),patch_temp(:,2),col) ;
