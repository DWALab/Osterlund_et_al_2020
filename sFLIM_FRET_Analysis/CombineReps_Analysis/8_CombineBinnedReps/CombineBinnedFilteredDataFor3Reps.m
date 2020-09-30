function CombineBinnedFilteredDataFor3Reps()
%Nehad Hirmiz
%Generate Kd Heatmaps from data for multiple reps 
%The data must be stored in a single excel file 
%Each rep data is stored in a seperate sheet
%data for rep 1 is stored in a sheet called "Rep1" and so forth 
    clc; clear all; close all;

    %%%%%%%%%%%%% USER DEFINED PARAMETERS %%%%%%%
    %%% BIN EDGES USED for ALL Replicates
    %%%% MAKE SURE THESE ARE THE SAME BINS AS THE ONES USED FOR BINNING
    %%%% EACH REPLICATE :) in Step 3
    bins =[-1,1,2,3,4,6,8,10,12,16,20,30,40,50];
    excel_file = 'directory\BclXL_platemaps_all reps.xlsx';
    sheet1 = 'Rep1';
    sheet2 = 'Rep2'; 
    sheet3 = 'Rep4';


    path_to_binned_data1 = 'directory\' ;
    path_to_binned_data2 = 'directory\' ;
    path_to_binned_data3 = 'directory\' ;
    combined_data_export_path = 'directory\'; 
    average_binned_export_path ='directory\'; 
    %Reading excel sheets loading up the data for each rep 
    %Numbers and text data are stored differently
    [num1, txt1] = xlsread(excel_file, sheet1);
    [num2, txt2] = xlsread(excel_file, sheet2);
    [num3, txt3] = xlsread(excel_file, sheet3);
    [rows,cols] = size(num1); 



    for i = 1:rows
        %Get well id from Rep1
        %because we have a row with labels the txt table will have an
        %additional row
        current_well = strcat(char(txt1(i+1,1)) , num2str(num1(i,1))); 
        
        if(strcmp(current_well,'I2'))
            disp('here')
        end
        celltype = txt1(i+1,3);
        transfection = txt1(i+1,4);
        drug = txt1(i+1,5);
        concentration = txt1(i+1,6);
        if(strcmp(transfection, 'Untransfected'))
            continue;
        end
        
        %Find the positoin of the same well in the other reps
        well_pos_rep2 = GetWellPositionInTable(txt2,celltype,transfection,drug,concentration); 
        well_pos_rep3 = GetWellPositionInTable(txt3,celltype,transfection,drug,concentration); 
        
        if well_pos_rep2 == -1
            well_2_id = 'blank';
        else
            well_2_id = strcat(char(txt2(well_pos_rep2,1)) , num2str(num2(well_pos_rep2-1,1))); 

        end
    

        if well_pos_rep3 == -1
            well_3_id = 'blank' ; 
        else
            well_3_id = strcat(char(txt3(well_pos_rep3,1)) , num2str(num3(well_pos_rep3-1,1))); 
        end
        

        binned_data1_path = strcat(path_to_binned_data1,'combined_',current_well,'_filtered_raw_binned.csv'); 
        binned_data2_path = strcat(path_to_binned_data2,'combined_',well_2_id,'_filtered_raw_binned.csv'); 
        binned_data3_path = strcat(path_to_binned_data3,'combined_',well_3_id,'_filtered_raw_binned.csv'); 
        




    
        
        
        if isfile(binned_data1_path)
            data1 = csvread(binned_data1_path,2); 
        else 
            continue;
        end
        
        if isfile(binned_data2_path)
            data2 = csvread(binned_data2_path,2); 
        else 
            data2 = NaN(size(data1)); 
        end

        if isfile(binned_data3_path)
            data3 = csvread(binned_data3_path,2); 
        else 
            data3 = NaN(size(data1)); 
        end 
        
        
        
        comb_data =vertcat(data1,data2,data3); 
        good_data = ~(isnan(comb_data(:,1))); 
        comb_data = comb_data(good_data,:); 
        

        export_filename = strcat(combined_data_export_path,'combined_filtered_raw_binned_',current_well,'.csv'); 
        col_names = {'Binned_Free_Acceptor','Binned_Bound_Fraction','Bin_std_error','Point_Per_Bin'}; 
        SaveToCSVWithColumnNames(export_filename,comb_data,col_names); 
    %     csvwrite(export_filename,comb_data); 
        

        %Lets average the binned data for all the reps
        [rep_binned_ven, rep_binned_bf, rep_bf_stderr] = BinRepsDataV3(comb_data(:,1),comb_data(:,2),bins);
        
        
        export_avg_rep_fname = strcat(average_binned_export_path,'CombinedAvgBinnedReps_',current_well,'.csv'); 
        avg_data = zeros(length(rep_binned_bf),3); 
        avg_data(:,1) = rep_binned_ven'; 
        avg_data(:,2) = rep_binned_bf'; 
        avg_data(:,3) = rep_bf_stderr'; 
        
        col_names = {'AvBinned_Free_Acceptor','AvBinned_Bound_Fraction','Bin_std_error'}; 
    %     csvwrite(export_avg_rep_fname,avg_data); 
        SaveToCSVWithColumnNames(export_avg_rep_fname,avg_data,col_names);
        
        
    end
    disp(['[INFO] Completed combining all replicates Analysis']);
 end
