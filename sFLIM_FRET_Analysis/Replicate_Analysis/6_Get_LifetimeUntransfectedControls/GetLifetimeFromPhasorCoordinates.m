%Nehad Hirmiz
%2019-05-29
%Generate Kd Heatmaps from data for multiple reps 
%The data must be stored in a single excel file 
%Each rep data is stored in a seperate sheet
%data for rep 1 is stored in a sheet called "Rep1" and so forth 
clc; clear all; close all;



%%%%Insert directory path to the Untransfected_Phasor_Coordinates file
path_to_phasor_coordinate = 'directory' ;
excel_file = fullfile(path_to_phasor_coordinate, 'Untransfected_Phasor_Coordinates.xlsx'); 



%Reading excel sheets loading up the data for each rep 
%Numbers and text data are stored differently
[num1, txt1] = xlsread(excel_file, 'Sheet1');
[rows,cols] = size(txt1); 

average_data_table = cell(rows,5); 

average_data_table(1,1) = {'Cells'}; 
average_data_table(1,2) = {'Transfection'}; 
average_data_table(1,3) = {'Drug'}; 
average_data_table(1,4) = {'Concentration'}; 
average_data_table(1,5) = {'Fluorescence_Lifetime'}; 




 for i = 1:rows
     %Get well id from Rep1
     %because we have a row with labels the txt table will have an
     %additional row
     current_well = strcat(char(txt1(i,1)) , num2str(num1(1,1))); 
     

     celltype = txt1(i,1);
     transfection = txt1(i,2);
     drug = txt1(i,3);
     concentration = txt1(i,4);
     
     
     
     average_data_table(i,1) = celltype; 
     average_data_table(i,2) = transfection; 
     average_data_table(i,3) = drug; 
     average_data_table(i,4) = concentration; 
     
     average_data_table(i,5) = {CalculateLifetimeFromPhasorCoordinate(num1(i,1),num1(i,2))}; 
     %Find the positoin of the same well in the other reps
    
 end
   

 xlswrite(fullfile(pwd,'UntransfectedLifetimeFromPhasor.xlsx'),average_data_table); 

 disp('Completed calculating lifetime from phasor coordinates'); 
    

    
    
 
