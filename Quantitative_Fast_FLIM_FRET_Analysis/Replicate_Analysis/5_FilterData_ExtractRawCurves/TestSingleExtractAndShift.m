%%% A testing fucntion to look at filtered data for a single well
%%% used for testing and prototyping purposes

filename =  'E:\FinalScreenData\mim2_BclXL\Rep1_20190320\combined_CSVs\combined_H5.csv'; 
mc3_gradient_slope = 0.6031; 
ven_gradient_slope = 0.0407; 
G_donor = 0.6554; 
S_donor = 0.4760; 
unbound_lifetime = 3786.6; 

bleedthrough = [0.0009 0.8560 -12.2173] ;
acceptor_shift = 1.820;
[~,~] = CurveExtractionAndShift(filename,bleedthrough_polyfit,G_donor,S_donor,unbound_lifetime, mc3_gradient_slope,ven_gradient_slope,acceptor_shift,false);        
