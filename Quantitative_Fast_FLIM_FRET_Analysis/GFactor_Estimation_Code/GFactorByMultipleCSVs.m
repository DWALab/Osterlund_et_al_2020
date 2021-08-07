
%%%%% USER DEFINED PARAMETERS %%%%

data_path = 'E:\INO\20190704_CorrectionFactor_Data_rep2_Compressed\G-Factor Analysis\Results_MATLAB_setROIs';
mc3_slope = 0.5267;
ven_slop = 0.0463; 
mc3_only_well_id = 'C2' ;
construct_1_well_id = 'C5';
construct_2_well_id = 'C6' ;
construct_3_well_id = 'C7'; 
construct_4_well_id = 'C4'; 

%%%%% OPTIONAL
mc3_concentration_lowerbound = 1;
mc3_concentratoin_upperbound  = 5;


fov_num = 0;
S = dir(fullfile(data_path,'*.csv')); % pattern to match filenames.
%%%%%% USE mCerulean3 Cells to calculate donor bleedthrough in the acceptor channel
data = [] ;
for k = 1:numel(S)
    fname = S(k).name;
    if contains(fname,mc3_only_well_id)
        curr_data =csvread(fullfile(data_path,fname)); 
        disp(size(curr_data)); 
        data = vertcat(data,curr_data); 
    end
    
end

mc3_concentration = data(:,2) * mc3_slope; 
k = find(mc3_concentration>=mc3_concentration_lowerbound & mc3_concentration <mc3_concentratoin_upperbound); 
data = data (k,:); 
f = fit(data(:,1),data(:,3),'m*x+b');
bleedthrough_slope = f.m ; 
bleedthrough_intercept = f.b; 


%%%% UNCOMMENT IF YOU WANT TO SAVE DONOR BLEEDTHROUGH PROFILE
%csvwrite(fullfile(data_path,'combined_mCerulean3_bleedthrough_profile.csv'),data); 


mc3_only = []; 

construct_1 = []; 
construct_2 = []; 
construct_3 = [] ; 
construct_4 = [];  

for k = 1:numel(S)
    fname = S(k).name;
    if contains(fname,mc3_only_well_id)
        curr_data =csvread(fullfile(data_path,fname)); 
        mc3_only = vertcat(mc3_only,curr_data); 
    elseif contains(fname,construct_1_well_id ) 
        curr_data =csvread(fullfile(data_path,fname)); 
        construct_1 = vertcat(construct_1,curr_data); 
    elseif contains(fname,construct_2_well_id ) 
        curr_data =csvread(fullfile(data_path,fname)); 
        construct_2 = vertcat(construct_2,curr_data); 
    elseif contains(fname,construct_3_well_id )
        curr_data =csvread(fullfile(data_path,fname)); 
        construct_3 = vertcat(construct_3,curr_data); 
    elseif contains(fname,construct_4_well_id ) 
        curr_data =csvread(fullfile(data_path,fname)); 
        construct_4 = vertcat(construct_4,curr_data); 
    end
    
end

[mc3_mc3, ven_mc3, lifetime_mc3] = CalcConcentratrionsV2(mc3_only,bleedthrough_slope,bleedthrough_intercept,mc3_slope,ven_slope);  
[mc3_conc1, ven_con1, lifetime1] = CalcConcentratrionsV2(construct_1,bleedthrough_slope,bleedthrough_intercept,mc3_slope,ven_slope);  
[mc3_conc2, ven_con2, lifetime2] = CalcConcentratrionsV2(construct_2,bleedthrough_slope,bleedthrough_intercept,mc3_slope,ven_slope);  
[mc3_conc3, ven_con3, lifetime3] = CalcConcentratrionsV2(construct_3,bleedthrough_slope,bleedthrough_intercept,mc3_slope,ven_slope);  
[mc3_conc4, ven_con4, lifetime4] = CalcConcentratrionsV2(construct_4,bleedthrough_slope,bleedthrough_intercept,mc3_slope,ven_slope);  

untransfected_lifetime = mean(lifetime_mc3); 
fret0 = 1 - (lifetime_mc3/untransfected_lifetime);
fret1 = 1 - (lifetime1/untransfected_lifetime); 
fret2 = 1 - (lifetime2/untransfected_lifetime); 
fret3 = 1 - (lifetime3/untransfected_lifetime);
fret4 = 1 - (lifetime4/untransfected_lifetime); 

fret1(fret1<0) = 0; 
fret2(fret2<0) = 0 ;
fret3(fret3<0) = 0;
fret4(fret4<0) = 0 ;

diff0 = ven_mc3 - mc3_mc3; 
diff1 = ven_con1 - mc3_conc1; 
diff2 = ven_con2 - mc3_conc2; 
diff3 = ven_con3 - mc3_conc3; 
diff4 = ven_con4 - mc3_conc4; 

XX = vertcat(mc3_conc1,mc3_conc2,mc3_conc3,mc3_conc4); 
YY = vertcat(fret1,fret2,fret3,fret4); 
ZZ = vertcat(diff1,diff2,diff3,diff4); 
plot(ZZ./XX,YY,'k.');

f = fit([XX,YY],ZZ,'-g*x*y/(y-1)');
disp(f.g); 


plot(f,[XX,YY],ZZ); 




%%%%%% OPTIONAL Uncomment remaining Lines for further FRET filtering

%[h1,c1] = hist(fret1,100);
% [h2,c2] = hist(fret2,100);
% [h3,c3] = hist(fret3,100);
% [h4,c4] = hist(fret4,100);
% n1 = c1/max(c1); 
% n1 = h1/max(h1); 
% n2 = h2/max(h2); 
% n3 = h3/ max(h3); 
% n4 = h4 / max(h4); 
% n1 = c1/max(c1); 
% n1 = h1/max(h1); 
% n2 = h2/max(h2); 
% n3 = h3/ max(h3); 
% n4 = h4 / max(h4);
% figure;
% hold on ;
% plot(c1,n1,'r-');
% plot(c2,n2,'g-'); 
% plot(c3,n3,'b-');
% plot(c4,n4,'k-');
% xlim([0,0.5]); 



% [filter_mc3_1,filtered_fret_1,filtered_Fc_1] = FilterUsingFRETDelta(mc3_conc1,fret1,diff1,0.01);
% [filter_mc3_2,filtered_fret_2,filtered_Fc_2] = FilterUsingFRETDelta(mc3_conc2,fret2,diff2,0.01);
% [filter_mc3_3,filtered_fret_3,filtered_Fc_3] = FilterUsingFRETDelta(mc3_conc3,fret3,diff3,0.01);
% [filter_mc3_4,filtered_fret_4,filtered_Fc_4] = FilterUsingFRETDelta(mc3_conc4,fret4,diff4,0.01);



% fXX = vertcat(filter_mc3_1,filter_mc3_2,filter_mc3_3,filter_mc3_4); 
% fYY = vertcat(filtered_fret_1,filtered_fret_2,filtered_fret_3,filtered_fret_4); 
% fZZ = vertcat(filtered_Fc_1,filtered_Fc_2,filtered_Fc_3,filtered_Fc_4); 
% figure; 
% f = fit([fXX,fYY],fZZ,'-g*x*y/(y-1)');
% disp(f.g); 

% plot(f,[fXX,fYY],fZZ); 





    