% Script originally created by Dr. Nehad Hirmiz
% Do not remove this comment please
clear all; 
close all; 
clc; 

disp('[INFOR] ANALYZING DATA...'); 
%%%%% USER DEFINED PARAMETERS %%%%% 

max_free_acceptor_concentration = 50; %in uM

%%Define range at which maximum bound fraction saturation should occur
saturation_start = 30 ; 
saturation_end = 50 ; 
%%% Path to excel file containing the Master Platemap
excel_file = 'directory\MasterPlatemap.xlsx';
%%% Input sheet name for Rep1
excel_sheet ='Rep1';

%%% Path Combined Binned data. Make sure it ends with '\'
path_to_binned_csv = 'directory\';

%%% Input Cells and Transfectants with reference to the platmap
%%% example : cells = {{'mC3-BclXL'},{'mC3-Bcl2'}, {'mC3-BclW'}, {'mC3-MCL1'}}; 
cells = {{'CellName1'},{'CellName2'}}; 
transfection_references = {{'Transfection1'},{'Transfection2'},{'Transfection3'},{'Transfection4'},{'Transfection5'}};
negative_references = {{'Neg Control1'},{'Neg Control2'},{'Neg Control3'},{'Neg Control4'},{'Neg Control5'}};

%%%%%%% ANALYSIS STARTS HERE %%%%%%%%%%%%

[num, txt] = xlsread(excel_file, excel_sheet);
[rows, cols] = size(txt); 
kd_array =zeros(rows,1); 
ci_lower_array = zeros(rows,1); 
ci_upper_array = zeros(rows,1); 
num_ROIs_array = zeros(rows,1);
r_squared_array = zeros(rows,1); 
col_names = txt(1,:); 

%%% Constructing Control Table
%% Control table stores infromation about which negative and postive control to consider when analyzing a given well
%% please note that we use 'DMSO' as our control. Make sure the correct media is indicated in the excel sheet and when using
%% GetWellPositionInTable() function
control_table = cell(length(transfection_references)*length(cells)+1,9);
control_index=1;

for c = 1:length(cells)
    for t = 1:length(transfection_references)
    current_cell = cells{c}; 
    positive_control = transfection_references{t};
    negative_control = negative_references{t}; 
    %disp([cell,positive_control, negative_control]);
    positive_control_index =  GetWellPositionInTable(txt,current_cell,positive_control,'DMSO','');
    negative_control_index =  GetWellPositionInTable(txt,current_cell,negative_control,'DMSO','');
      
    if positive_control_index == -1 || negative_control_index == -1
        continue
    end
    if(positive_control_index > 0) && (negative_control_index > 0 ) 
    
        positive_wellid = strcat(char(txt(positive_control_index)), num2str(num(positive_control_index - 1,1))); 
        negative_wellid = strcat(char(txt(negative_control_index)), num2str(num(negative_control_index - 1,1))); 
        
        
        positive_filename = strcat(path_to_binned_csv,'combined_',positive_wellid,'_binnedReps.csv') ;  
        negative_filename = strcat(path_to_binned_csv,'combined_',negative_wellid,'_binnedReps.csv') ;  
        
        positive_filename = char(positive_filename); 
        negative_filename = char(negative_filename); 
        pos_inter_point = FindInterpolatedPoint(positive_filename); 
        neg_inter_point = FindInterpolatedPoint(negative_filename); 
        
        control_table(control_index,1) = current_cell; 
        control_table(control_index,2) = positive_control; 
        control_table(control_index,3) = {positive_wellid}; 
        control_table(control_index,4) = negative_control; 
        control_table(control_index,5) = {negative_wellid}; 
        control_table(control_index,6) = {pos_inter_point};
        control_table(control_index,7) = {neg_inter_point}; 
    else
        positive_wellid = strcat(char(txt(positive_control_index)), num2str(num(positive_control_index - 1,1))); 
        negative_wellid = strcat(char(txt(negative_control_index)), num2str(num(negative_control_index - 1,1))); 
%         [sat_parameter,fit_ratio] =  GetSaturationParameterAndFitRatio(sattxt,satnum,current_cell,positive_control,'DMSO'); 
        
        control_table(control_index,1) = current_cell; 
        control_table(control_index,2) = {positive_control}; 
        control_table(control_index,3) = {'NotFound'}; 
        control_table(control_index,4) = {negative_control}; 
        control_table(control_index,5) = {'NotFound'}; 
        control_table(control_index,6) = {'NaN'};
        control_table(control_index,7) = {'NaN'};
    
    end
    %update index
    control_index = control_index + 1; 
    
    end
    
    
end


%%% Loop through wells
for c = 1:(length(transfection_references)*length(cells)+1)

   bound_fraction_difference =  control_table{c,6} - control_table{c,7};
   
   if bound_fraction_difference < 0.05
            disp(['Diff between ', control_table{c,1},' + ' ,control_table{c,2}, ' vs ', control_table{c,4}, ' is insufficient']);
       
   end
        
   if bound_fraction_difference > 0.05
       reference_well_id= control_table{c,3} ; 
       reference_fname = strcat(path_to_binned_csv,'combined_' ,reference_well_id,'_binnedReps.csv') ;
       reference_filename = char(reference_fname);
       curve_data = csvread(reference_filename,2);
       tx = curve_data(:,1);
       ty = curve_data(:,2);
       [sorted_tx, Idx ] = sort(tx);
        sorted_ty = ty(Idx);
        iso_ty = lsqisotonic(sorted_tx,sorted_ty);

        max_data = median(iso_ty(end-6:end));
        if(max_data <0.05)
               max_data = 0.05;
        end 

        x = sorted_tx ; y = iso_ty; 
        y = y (x<=max_free_acceptor_concentration); 
        x = x (x<=max_free_acceptor_concentration); 
        x(x<0) = 0;
        y(y < 0) = 0; 

        x(y > max_data) = [];
        y(y > max_data) = [];


        rect = max_data * max(x); 
        auc = trapz(x,y);

        ratio = auc /(rect-auc); 
        control_table{c,8} = ratio; 
        
        if ratio < 2
            disp(['ShapeRatio is <2 for ', control_table{c,1},' + ' ,control_table{c,2}, ' curve data']);
        end
        
        %Let's examine the Ratio and calculate the saturation parameter for 
        %positive controls that have Ratio > 2 
        if ratio > 2
         sat_points = ty(tx > saturation_start & tx < saturation_end);
         estimated_sat_par = median(sat_points);   
         
         %Allow user to examine the saturation parameter and correct it
          plot(tx,ty,'k.','DisplayName','Data');
         hold on ;
         plot(sorted_tx,iso_ty,'r-', 'DisplayName','Isotonic Smoothing');
         plot(tx, ones(size(tx))*estimated_sat_par, 'b-', 'DisplayName','Estimated Saturation'); 
         if(min(ty) < estimated_sat_par + 0.1)
             ylim([min(ty),estimated_sat_par + 0.1]); 
         else
             ylim([0,0.1]) 
         end
         hold off;
         legend show;
         hold on; 
         hLegend = findobj(gcf, 'Type', 'Legend');
         hLegend.Location = 'northwest'; 
        %Ask user if saturation parameter is correct                        
         title(strcat('Estimated Saturation Parameter=', num2str(estimated_sat_par)));
         answer = input("Was the estimated saturation parameter correct?");
         if answer == -1
            estimated_sat_par = input('Please enter saturation parameter:');
            
         end  
         control_table{c,9} = estimated_sat_par ;
         
         
        else
            control_table{c,9} = NaN;
            
        end
         
        close all; 
        
   end
end



saturation_results_filename = strcat(path_to_binned_csv,'SatParameters_CombinedBinnedReps.csv');
new_table = control_table; 

new_table(2:end,:) = control_table(1:end-1,:); 
new_table{1,1} = 'Cells'; 
new_table{1,2} = 'Positive_Control'; 
new_table{1,3} = 'Positive_Control_WellID'; 
new_table{1,4} = 'Negative_Control'; 
new_table{1,5} = 'Negative_Control_WellID'; 
new_table{1,6} = 'Positive_Control_BF_10-20uM'; 
new_table{1,7} = 'Negative_Control_BF_10-20uM'; 
new_table{1,8} = 'Postive_Control_sRatio'; 
new_table{1,9} = 'Postive_Control_Saturation_Parameter'; 

xlswrite(saturation_results_filename,new_table); 

%%%%Part 3 Find the zero point from 4E Mutants

zero_point_table = []; 
zero_index_count = 1; 
kd_array = zeros(rows,1);
ci_lower_array = zeros(rows,1);
ci_upper_array = zeros(rows,1); 
num_ROIs_array = zeros(rows,1); 
% max_point_array = zeros(rows, 1); 
ratio_array= zeros(rows,1);
cum_sum_array= zeros(rows,1);
interpolation_point_array = zeros(rows,1); 
num_binned_points_array = zeros(rows,1); 
free_ven_array = zeros(rows,1) ;
drug_resistance_array = zeros(rows,1); 


for i = 2:rows 
    %if it is not untransfected then find the donor only
    if(isempty(char(txt(i,3))))
            continue;
        elseif(~strcmp(char(txt(i,4)),'Untransfected'))%Check that the cell is not Untransfected
            cell_type = char(txt(i,3));
            transfection  = char(txt(i,4)); 
            drug = char(txt(i,5));
            concentration = char(txt(i,6)); 

            %Create filname for the current well
            filename = strcat(path_to_binned_csv,'combined_',txt(i,1),num2str(num(i-1,1)),'_binnedReps.csv') ;  
            filename = char(filename);
            
            %Check if file exists
            if ( exist(filename, 'file'))
                [postive_interpolated_point,negative_interpolated_point,control_ratio,control_satpar] = GetControlParameters(control_table,cell_type,transfection);
                
                [kd, cil,ciu,FitRatio,cum_sum,num_of_ROIs,num_of_binned_points,interpolated_point,max_free_venus,DrugResistance] =  AnalyzeBindingData(filename, postive_interpolated_point,negative_interpolated_point,control_ratio,control_satpar);  
                kd_array(i,1) = kd ; 
                ci_lower_array(i,1) = cil; 
                ci_upper_array(i,1) = ciu; 
                ratio_array(i,1) = FitRatio;
                cum_sum_array(i,1) = cum_sum; 
                num_ROIs_array(i,1) = num_of_ROIs;
                num_binned_points_array(i,1) = num_of_binned_points+1; 
                interpolation_point_array(i,1) = interpolated_point; 
                free_ven_array(i,1) = max_free_venus;
                drug_resistance_array(i,1) = DrugResistance;
                
                

            else
      %File does not exist.
                 warningMessage = sprintf('Warning: file does not exist:\n');

                 filename
                 continue;
            end
       
        
    end
end

data_table = cell(16,rows); 

    

for i = 2:rows 
    well_letter = char(txt(i,1)); 
    well_id = num(i-1); 
    cell_type = char(txt(i,3));
    transfection  = char(txt(i,4)); 
    drug = char(txt(i,5));
    concentration = char(txt(i,6)); 
        
    data_table(i,1) = {well_letter}; 
    data_table(i,2) = {well_id} ;
    data_table(i,3) = {cell_type}; 
    data_table(i,4) = {transfection} ;
    data_table(i,5) = {drug}; 
    data_table(i,6) = {concentration}  ;        
    data_table(i,7) = {num_ROIs_array(i)};
    data_table(i,8) = {num_binned_points_array(i)};
    data_table(i,9) = {free_ven_array(i)};
    data_table(i,10) = {cum_sum_array(i)}; 
    data_table(i,11) = {interpolation_point_array(i)};
    data_table(i,12) = {drug_resistance_array(i)};
    data_table(i,13) = {ratio_array(i)};
    data_table(i,14) = {kd_array(i)};
    data_table(i,15) = {ci_lower_array(i)};
    data_table(i,16) = {ci_upper_array(i)}; 
    
    
end


data_table(1,1) = {'Row'};
data_table(1,2) = {'Column'}; 
data_table(1,3) = {'Cells'}; 
data_table(1,4) = {'Transfection'}; 
data_table(1,5) = {'Drug'}; 
data_table(1,6) = {'Concentration'};
data_table(1,7) = {'Num_ROIs_In_Curve'} ;
data_table(1,8) = {'Num_Binnedpoints_In_Curve'}; 
data_table(1,9) = {'Free_Venus_Concentration'}; 
data_table(1,10) = {'CumulativeSumAUC'}; 
data_table(1,11) = {'BF_10-20uM_free_Venus'};
data_table(1,12) = {'ResistancetoTreatment'};
data_table(1,13) = {'ShapeRatio'};
data_table(1,14) = {'Kd'};
data_table(1,15) = {'ConfInt_Lower'};
data_table(1,16) = {'ConfInt_Upper'};


results_filename = strcat(path_to_binned_csv,'CombinedBinnedReps_Results.xlsx'); 

xlswrite(results_filename, data_table); 


disp('[INFO] Completed Automated Kd Extraction'); 
close all
clear all

% 



