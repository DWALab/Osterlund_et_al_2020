%Nehad Hirmiz
%2019-05-29
%Generate Kd Heatmaps from data for multiple reps 
%The data must be stored in a single excel file 
%Each rep data is stored in a seperate sheet
%data for rep 1 is stored in a sheet called "Rep1" and so forth 
clc; clear all; close all;



%%%%%% USER DEFINED PARAMETERS %%%%%%%%%
path_to_donor_table1 = 'directory\' ;
path_to_donor_table2 = 'directory\' ;
path_to_donor_table3 = 'directory\' ;



average_data_export_path = pwd; 

excel_file1 = fullfile(path_to_donor_table1, 'Donor_Concentration_Table.xlsx'); 
excel_file2 = fullfile(path_to_donor_table2, 'Donor_Concentration_Table.xlsx'); 
excel_file3 = fullfile(path_to_donor_table3, 'Donor_Concentration_Table.xlsx'); 



%Reading excel sheets loading up the data for each rep 
%Numbers and text data are stored differently
[num1, txt1] = xlsread(excel_file1, 'Sheet1');
[num2, txt2] = xlsread(excel_file2, 'Sheet1');
[num3, txt3] = xlsread(excel_file3, 'Sheet1');



[rows,cols] = size(txt1); 

average_data_table = cell(rows,10); 
average_data_table(1,1) = {'Row'}; 
average_data_table(1,2) = {'Column'}; 
average_data_table(1,3) = {'Cells'}; 
average_data_table(1,4) = {'Transfection'}; 
average_data_table(1,5) = {'Drug'}; 
average_data_table(1,6) = {'Concentration'}; 
average_data_table(1,7) = {'Avg_Mean_Donor_Concentration'}; 
average_data_table(1,8) = {'Avg_Std_Donor_Concentration'} ;
average_data_table(1,9) = {'Avg_Median_Donor_Concentration'}; 
average_data_table(1,10) = {'Avg_Mode_Donor_Concentration'}; 



 for i = 2:rows
     %Get well id from Rep1
     %because we have a row with labels the txt table will have an
     %additional row
     current_well = strcat(char(txt1(i,1)) , num2str(num1(i-1,1))); 
     

     celltype = txt1(i,3);
     transfection = txt1(i,4);
     drug = txt1(i,5);
     concentration = txt1(i,6);
     
     average_data_table(i,1) = txt1(i,1) ; 
     average_data_table(i,2) = {num1(i-1,1)}; 
     average_data_table(i,3) = celltype; 
     average_data_table(i,4) = transfection; 
     average_data_table(i,5) = drug; 
     average_data_table(i,6) = concentration; 
     
     
     
     %Find the positoin of the same well in the other reps
     well_pos_rep2 = GetWellPositionInTable(txt2,celltype,transfection,drug,concentration); 
     well_pos_rep3 = GetWellPositionInTable(txt3,celltype,transfection,drug,concentration); 
   
    mean_donor_con = []; 
    std_donor_con = [];
    median_donor_con = []; 
    mode_donor_con = []; 
    

     mean_donor_con(1) = num1(i-1,6); 
     std_donor_con(1) = num1(i-1,7); 
     median_donor_con(1)=num1(i-1,8); 
     mode_donor_con(1) = numel(i-1,0); 
     
     
    if well_pos_rep2 ~= -1
        mean_donor_con(end+1) = num2(well_pos_rep2-1,6); 
        std_donor_con(end+1) = num2(well_pos_rep2-1,7); 
        median_donor_con(end+1)=num2(well_pos_rep2-1,8); 
        mode_donor_con(end+1) = num2(well_pos_rep2-1,9); 
    end
   

    if well_pos_rep3 ~= -1
        mean_donor_con(end+1) = num3(well_pos_rep3-1,6); 
        std_donor_con(end+1) = num3(well_pos_rep3-1,7); 
        median_donor_con(end+1)=num3(well_pos_rep3-1,8); 
        mode_donor_con(end+1) = num3(well_pos_rep3-1,9); 
    end
    


    mean_donor_con(isnan(mean_donor_con)) = [];
    std_donor_con(isnan(std_donor_con)) = []; 
    median_donor_con(isnan(median_donor_con)) = [] ; 
    mode_donor_con(isnan(mode_donor_con)) = [] ; 
    
    
    
    average_data_table(i,7) = {mean(mean_donor_con)}; 
    average_data_table(i,8) = {mean(std_donor_con)}; 
    average_data_table(i,9) = {mean(median_donor_con)}; 
    average_data_table(i,10) = {mean(mode_donor_con)}; 

      
 end
 
 xlswrite(fullfile(average_data_export_path,'Average_Donor_Concentration.xlsx'), average_data_table); 
 
 disp('[INFO] Completed Averaging Infomration from Multiple Reps'); 
 disp('[INFO] Generating Plate Maps from Average Information');
 
letters = ['A';'B';'C';'D';'E';'F';'G';'H';'I';'J';'K';'L';'M';'N';'O';'P'];
mean_map = zeros(length(letters),24);
std_map = zeros(size(mean_map)); 
median_map = zeros(size(mean_map));
mode_map = zeros(size(mean_map)); 



%Generate a map for plate map
%For a 384 well plate we have 24 columns (1 -24)
% and 16 rows (A-P); 
plate_map = cell(size(mean_map));
for l = 1:length(letters)
    for n = 1:24
    plate_map{l,n} = (strcat(letters(l), num2str(n)));
    end
end


%First two columns of the table  well ID.
[rows, cols] = size(num1);


 for i = 2:rows
      
     
     %Get well id from Rep1
     %because we have a row with labels the txt table will have an
     %additional row
     well_num  = average_data_table(i,2); 
     well_num = well_num{1}; 
     
     current_well = strcat(char(average_data_table(i,1)) , num2str(well_num)); 
     
    %Find the well id in the plate map 
    [map_row ,map_col] = find(strcmp(plate_map, current_well));
     
    %Populate the maps
    mean_map(map_row,map_col) = cell2mat(average_data_table(i,7));
    std_map(map_row,map_col) = cell2mat(average_data_table(i,8));
    median_map(map_row,map_col) = cell2mat(average_data_table(i,9));
    mode_map(map_row,map_col) = cell2mat(average_data_table(i,10));     
 end
 
 output_filename = fullfile(average_data_export_path,'Average_Donor_Concentration_Maps.xlsx');
 xlswrite(output_filename, mean_map,'mean_donor_map'); 
 xlswrite(output_filename, std_map, 'std_donor_map'); 
 xlswrite(output_filename, median_map, 'median_donor_map'); 
 xlswrite(output_filename, mode_map , 'mode_donor_map'); 
 
 disp('[INFO] Completed Analysis for Average Donor Concentration'); 
