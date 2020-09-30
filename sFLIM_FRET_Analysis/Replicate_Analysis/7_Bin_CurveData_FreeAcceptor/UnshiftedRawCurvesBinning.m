function  UnshiftedRawCurvesBinning()
%%%% This is the second step of sFLIM-FRET analysis
%%%% The steps are wrapped in a function so they can be called from multiple screens using MatLab
%%%% The extracted filtered_raw.csv files are passed to this function to generate binned data

    disp('[INFO] ANALZYING DATA ...'); 

    %%%%%%%%% USER DEFINED PARAMETERS%%%%%%%%%

    %Input Path to excel file containing the plate map 'here\'  Make sure it ends with '\'
        excel_file = 'path to platemap.xlsx';
    %Input name of sheet 'here' 
        excel_sheet ='Rep1';
        
    %Input Path to 1. Filter_data_ExtractRawCurves\RawCurves. Make sure it ends with '\' (windows path)
    path_to_raw_csv = 'path to raw curves\';


    %(don't change) Path to save analysis= within working directory subfolder 'Binned_Curves'
    current_path = pwd; 

        
    binned_curves_subfolder  = fullfile(current_path,'Phasor_Binned_Curves'); 

    %option to use INO analysis if needed. We do not use this here.  
    binned_ino_curves_subfolder = fullfile(current_path, 'INO_Binned_Curves'); 

    %option to use AD intensity Ratio vs FRET analysis if needed. We do not use this here.  
    binned_ADFRET_curves_subfolder  = fullfile(current_path,'AD_FRET_Binned_Curves'); 


    %Create subfolders to in the script folder to save generatefiles
    if ~exist(binned_curves_subfolder,'dir')
        mkdir(binned_curves_subfolder)
    end

    if ~exist(binned_ino_curves_subfolder,'dir')
        mkdir(binned_ino_curves_subfolder)
    end

    if ~exist(binned_ADFRET_curves_subfolder,'dir')
        mkdir(binned_ADFRET_curves_subfolder)
    end


    %%%%%%%% ANALYSIS STARTS HERE %%%%%%%%%%
    [num, txt] = xlsread(excel_file, excel_sheet);
    [rows, cols] = size(txt); 
    %loop through wells
    for i = 2:rows 
        %if it is not untransfected then find the donor only
        if(isempty(char(txt(i,3))))
            continue;
        elseif(~strcmp(char(txt(i,4)),'Untransfected'))%Check that the cell is not Untransfected
            cell_type = char(txt(i,3));
            transfection  = char(txt(i,4)); 
            drug = char(txt(i,5));
            concentration = char(txt(i,6)); 
 
        
            filename = strcat(path_to_raw_csv,'combined_',txt(i,1),num2str(num(i-1,1)),'_filtered_raw.csv') ;  
            filename = char(filename);
                if ( exist(filename, 'file'))     
                    BinRawUnshiftedData(filename );        
                else
                %File does not exist.
                    warningMessage = sprintf('[WARNING] file does not exist:\n');                
                    filename
                    continue;
                end
        end
        
        
        %%lets extract concentration information from filtered data
        %following are titles
        concentration_table = cell(10,rows); 
        concentration_table(1,1) = {'Row'};
        concentration_table(1,2) = {'Column'}; 
        concentration_table(1,3) = {'Cells'}; 
        concentration_table(1,4) = {'Transfection'}; 
        concentration_table(1,5) = {'Drug'}; 
        concentration_table(1,6) = {'Concentration'};
        concentration_table(1,7) = {'Mean Donor Concentration'} ;
        concentration_table(1,8) = {'Std Donor Concentration'}; 
        concentration_table(1,9) = {'Median Donor Concentration'}; 
        concentration_table(1,10) = {'Mode Donor Concentration'}; 
        
        

        %%%% In this part of the script we extract information about the concentration of proteins 
        %%%% in the bin data
        %%%% The observed Kd(s) depends on what concentration of the two proteins are available
        %%%% In the case we observe an anamoly in the REPs, it is easy to findout if the well had lower/higher concentrations of proteins

        for i = 2:rows 
        well_letter = char(txt(i,1)); 
        well_id = num(i-1); 
        cell_type = char(txt(i,3));
        transfection  = char(txt(i,4)); 
        drug = char(txt(i,5));
        concentration = char(txt(i,6)); 
            
        concentration_table(i,1) = {well_letter}; 
        concentration_table(i,2) = {well_id} ;
        concentration_table(i,3) = {cell_type}; 
        concentration_table(i,4) = {transfection} ;
        concentration_table(i,5) = {drug}; 
        concentration_table(i,6) = {concentration}  ; 
        filename = strcat(path_to_raw_csv,'combined_',txt(i,1),num2str(num(i-1,1)),'_filtered_raw.csv') ;  
        filename = char(filename);
        if ( exist(filename, 'file'))
                    
            data = csvread(filename,2); 
            mc3_concentration = data(:,2);
            mc3_concentration(isnan(mc3_concentration)) = []; 
            concentration_table(i,7) = {mean(mc3_concentration)}; 
            concentration_table(i,8) = {std(mc3_concentration)}; 
            concentration_table(i,9) = {median(mc3_concentration)}; 
            concentration_table(i,10) = {mode(mc3_concentration)};                                  
            
        else
            %File does not exist.
            concentration_table(i,7) = {''}; 
            concentration_table(i,8) = {''}; 
            concentration_table(i,9) = {''}; 
            concentration_table(i,10) = {''}; 
            warningMessage = sprintf('Warning: file does not exist:\n');
            disp('The following file was not found:\n');
            filename
            continue;
                
            
        end
        end
        
        output_xls_filename = fullfile(current_path,'Donor_Concentration_Table.xlsx'); 
        xlswrite(output_xls_filename, concentration_table); 
    

    end
    disp(['[INFO] Completed Binning Analysis',pwd]); 
    
end
