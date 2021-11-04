% Function to calculate solution to Haine & Hall (2002) box model.
% twnh Sep 00, Aug 02, Oct 11.

function concs = box_model(init_concs, times, forcing)
%                          init_concs                        9x1 vector of initial concentrations.
%                                      times                 Vector of times (years) for output of model.
%                                             forcing        9xlength(times) vector of time-dependent concentrations that each box relaxes to.

global A                                                   % To communicate with run_box_model.m

% Check input variables
if(length(init_concs) ~= length(A) || size(forcing,1) ~= length(A) || size(forcing,2) ~= length(times))
    fprintf(1,' ERROR in box_model.m: Wrong sizes of arguments.\n\n') ;
    keyboard
end % if

% Setup local variables
global local_forcing local_times V D Vi tf                 % To communicate with box_model_int.m
local_forcing = forcing ;
local_times   = times ;
fun_h         = @box_model_int ;

% Find propagator by analytical expression using eigen-methods.
% Eigenanalysis of transport matrix
if(isempty(V))      % Do this once only at startup.
   [V,D] = eig(A) ;
   Vi    = inv(V) ;
end % if

% Compute solution.
concs = zeros(length(A),length(times)) ;
for tt = 1:length(times)
   concs(:,tt) = V*expm(D.*times(tt))*Vi*init_concs ;               % Initial condition contribution
   tf = times(tt) ;
   if(any(any(forcing)))
      concs(:,tt) = concs(:,tt) + integral(fun_h,0,tf,'ArrayValued',true,'Waypoints',local_times) ;  % Forcing contribution. Waypoints ensures the discontinuous forcing function is handled right.
   end % if
end % tt

concs = real(concs) ;      % Cut imaginary part which is zero to machine precision.

return
