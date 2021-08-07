function [mc3_conc, ven_con, lifetime] = CalcConcentratrionsV2(data,bleedthrough_polyfit,mc3_slope,ven_slope)
mc3 = data(:,1) ;
T0 = data(:,2); 
Ven = data(:,3); 
tau = data(:,4); 

mc3_conc = T0 * mc3_slope; 
% ven_corr = Ven - (mc3 * 1.2014) ;
% ven_corr = Ven - (mc3 * bleedthrough_slope + bleedthrough_intercept);
ven_corr = bleedthrough_polyfit(1)*mc3.^2 + bleedthrough_polyfit(2)*mc3 + sign(bleedthrough_polyfit(3)).*bleedthrough_polyfit(3);
ven_corr = Ven - ven_corr;
ven_con = ven_corr * ven_slope; 

ven_con = ven_con(mc3_conc < 8 & mc3_conc > 0.5); 
lifetime = tau (mc3_conc < 8 & mc3_conc > 0.5); 
mc3_conc = mc3_conc(mc3_conc < 8 & mc3_conc > 0.5); 

ven_con = ven_con( ~isnan(lifetime)); 
mc3_conc = mc3_conc(~isnan(lifetime)); 
lifetime = lifetime(~isnan(lifetime)); 


end

