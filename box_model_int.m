% Intermediate function to integrate box model.
% twnh Oct 11.
function integrand = box_model_int(tp)

global local_forcing local_times V D Vi B tf fwd_interp_method

this_forcing = interp1(local_times',local_forcing',tp,fwd_interp_method)' ;     % Use interpolation between data points in forcing timeseries.
integrand    = V*expm(D.*(tf-tp))*Vi*B*this_forcing ;

return
