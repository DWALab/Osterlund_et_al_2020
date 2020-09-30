%Nehad Hirmiz
%2019-05-29
%Generate Kd Heatmaps from data for multiple reps 
%The data must be stored in a single excel file 
%Each rep data is stored in a seperate sheet
%data for rep 1 is stored in a sheet called "Rep1" and so forth 
clc; clear all; close all;

excel_path = 'Path to platemap\';
excel_filename = 'PreliminaryKd_Results.xlsx';
excel_fullpath = fullfile(excel_path,excel_filename); 
sheet1 = 'sheet1';


%Reading excel sheets loading up the data for each rep 
%Numbers and text data are stored differently
[num1, txt1] = xlsread(excel_fullpath, sheet1);


well_id = txt1(:,1);
%generate plate map
letters = ['A';'B';'C';'D';'E';'F';'G';'H';'I';'J';'K';'L';'M';'N';'O';'P'];
num_ROIs_map  = zeros(length(letters),24);
num_binned_points_map = zeros(size(num_ROIs_map));
interpolated_bf_map = zeros(size(num_ROIs_map)); 
max_free_ven_map = zeros(size(num_ROIs_map));
area_cumsum_map = zeros(size(num_ROIs_map));
drugResistance_map = zeros(size(num_ROIs_map));
FitRatio_map = zeros(size(num_ROIs_map)); 
kd_map = zeros(size(num_ROIs_map));
ci_lower_map = zeros(size(num_ROIs_map)); 
ci_upper_map = zeros(size(num_ROIs_map));

%Generate a map for plate map
%For a 384 well plate we have 24 columns (1 -24)
% and 16 rows (A-P); 
plate_map = cell(size(num_ROIs_map));
for l = 1:length(letters)
    for n = 1:24
    plate_map{l,n} = (strcat(letters(l), num2str(n)));
    end
end

%First two columns of the excel sheet indicate the well ID.
[rows, cols] = size(num1);

 for i = 1:rows
      
     
     %Get well id from Rep1
     %because we have a row with labels the txt table will have an
     %additional row
     current_well = strcat(char(txt1(i+1,1)) , num2str(num1(i,1))); 
     celltype = txt1(i+1,3);
     transfection = txt1(i+1,4);
     drug = txt1(i+1,5);
     concentration = txt1(i+1,6);
          
     %Using the position (row-wise) find the kd calculated for that
     %condition
     num_ROIs = num1(i,6);
     num_binned_points = num1(i,7);
     max_free_ven = num1(i,8);
     area_cumsum= num1(i,9);
     interpolated_bf = num1(i,10); 
     drug_resistance = num1(i,11); 
     FitRatio = num1(i,12);  
     kd = num1(i,13); 
     ci_lower = num1(i,14); 
     ci_upper = num1(i,15); 
     
     %Find the well id in the plate map 
    [map_row ,map_col] = find(strcmp(plate_map, current_well));
     
    %Populate the maps
    num_ROIs_map (map_row,map_col) = num_ROIs; 
    num_binned_points_map(map_row,map_col)= num_binned_points;
    max_free_ven_map (map_row,map_col) = max_free_ven;
    area_cumsum_map(map_row,map_col) = area_cumsum; 
    interpolated_bf_map (map_row,map_col) = interpolated_bf; 
    drugResistance_map (map_row,map_col) = drug_resistance;
    FitRatio_map (map_row,map_col) = FitRatio;  
    kd_map(map_row,map_col) = kd ;
    ci_lower_map (map_row,map_col) = ci_lower; 
    ci_upper_map(map_row,map_col) = ci_upper;
     
 end
 
 %Save results to an excel sheet
 output_filename = fullfile(excel_path,'GeneratedHeatMapsPreliminary.xlsx');
 xlswrite(output_filename, num_ROIs_map , 'Num_ROIs in curve'); 
 xlswrite(output_filename, num_binned_points_map , 'Num_binned points in curve'); 
 xlswrite(output_filename, max_free_ven_map, 'Max_free_Venus concentration');
 xlswrite(output_filename, area_cumsum_map, 'Area_of_CumulativeSum');
 xlswrite(output_filename, interpolated_bf_map,'interpolated_bf_10-20uM');
 xlswrite(output_filename, drugResistance_map,'%DrugResistance');
 xlswrite(output_filename, FitRatio_map , 'sRatio'); 
 xlswrite(output_filename, kd_map,'kd_map'); 
 xlswrite(output_filename, ci_lower_map, 'ci_lower'); 
 xlswrite(output_filename, ci_upper_map, 'ci_upper'); 

 %imagesc(kd_map)

  disp('Completed GenerateParameterMaps'); 
