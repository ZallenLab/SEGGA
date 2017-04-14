function dist = line_par_point_dist_2d ( f, g, x0, y0, p )

%% LINE_PAR_POINT_DIST_2D: distance ( parametric line, point ) in 2D.
%
%  Discussion:
%
%    The parametric form of a line in 2D is:
%
%      X = X0 + F * T
%      Y = Y0 + G * T
%
%  Modified:
%
%    20 February 2005   %vecotrized 10 June 2006 --Ori
%
%  Author:
%
%    John Burkardt
%
%  Reference:
%
%    Adrian Bowyer and John Woodwark,
%    A Programmer's Geometry,
%    Butterworths, 1983.
%
%  Parameters:
%
%    Input, real F, G, X0, Y0, the parametric line parameters.
%
%    Input, real P(2), the point whose distance from the line is
%    to be measured.
%
%    Output, real DIST, the distance from the point to the line.
%
  

  dx =   g .* g .* ( p(1,:) - x0 ) - f .* g .* ( p(2,:) - y0 );
  dy = - f .* g .* ( p(1,:) - x0 ) + f .* f .* ( p(2,:) - y0 );

  dist = realsqrt ( dx .* dx + dy .* dy ) ./ ( f .* f + g .* g );

