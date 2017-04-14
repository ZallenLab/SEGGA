function value = angle_rad_2d_vec ( x, y )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  x = [P1(1) P2(1) P3(1)]   %
%  y = [P1(2) P2(2) P3(2)]   %
%  These can be vectors      % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ANGLE_RAD_2D returns the angle swept out between two rays in 2D.
%
%  Discussion:
%
%    Except for the zero angle case, it should be true that
%
%      ANGLE_RAD_2D(P1,P2,P3) + ANGLE_RAD_2D(P3,P2,P1) = 2 * PI
%
%        P1
%        /
%       /    
%      /     
%     /  
%    P2--------->P3
%
%  Modified:
%
%    18 February 2005   
%    17 July 2007 - vectorized  -- Ori
%
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, real P1(2), P2(2), P3(2), define the rays
%    P1 - P2 and P3 - P2 which in turn define the angle.
%
%    Output, real VALUE, the angle swept out by the rays, measured
%    in radians.  0 <= VALUE < 2*PI.  If either ray has zero length,
%    then VALUE is set to 0.
%
  p = zeros(length(x(:,1)), 2);
  p(:, 1) = ( x(:, 3) - x(:, 2) ) .* ( x(:, 1) - x(:, 2) ) ...
       + ( y(:, 3) - y(:, 2) ) .* ( y(:, 1) - y(:, 2) );

  p(:, 2) = ( x(:, 3) - x(:, 2) ) .* ( y(:, 1) - y(:, 2) ) ...
       - ( y(:, 3) - y(:, 2) ) .* ( x(:, 1) - x(:, 2) );

  value = atan2 ( p(:, 2), p(:, 1) );
  ind = value < 0;
  value(ind) = value(ind) + 2 * pi;

