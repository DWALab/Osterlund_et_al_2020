 
function  FilteredDataExportationConstantTx()
%%%% FIRST STEP in the Analysis 
%%% Here we take the raw CSV files generated from the INO FHS and filter them 
%%% A copy of the filtered CSV is saved 
%%% The export path is defined in the USER DEFINED PARAMETERS SECTION
%%% the exported files have the following name: WellID_XX_filtered_raw.csv
%%% Example WellID_C21_filtered_raw.csv




    %%%%%%%%%%%%%%%%% USER DEFINED PARAMETERS%%%%%%%%%%%%%%%%
    % optional enter Experiment name and date below (...)
    disp('[INFO] Extracting Data ...'); 
    %%%Input Path to excel file containing the plate map 'here\'  Make sure it ends with '\'
    excel_file = 'Directory to platemap.xlsx';
    %%%Input name of sheet 'here' 
    excel_sheet ='Rep1';
    
    %%%In platemap, input name of cell line(s) {{'cell line'},{'cell line2'}} 
    %Create an empty table to hold data for saturation parameters
    cells = {{'cellname'},{'cellname'},{'cellname'},{'cellname'}}; 

    %%%Input Path to combined CSV files. Make sure it ends with '\'
    path_to_combined_csv = 'directory to combinedCSVs\';

    %%%Input the slope of the line for Venus and mCerulean3 protein gradients
    ven_gradient_slope =  ; 
    mc3_gradient_slope =  ;

    %(don't change) Path to save analysis within working directory subfolder 'RawCurves'
    current_path = pwd; 
    path_to_analysis_folder = fullfile(current_path,'RawCurves');

    
    [num, txt] = xlsread(excel_file, excel_sheet);
    [rows, cols] = size(txt); 


    %%%%%%%%%%%%%%%%%%%%%% ANALYSIS SCRIPT STARTS HERE %%%%%%%%%%%%%%%%%%%%%%%%
    
    %Build Table for Untransfected Phasor Coordinates
    untransfected_indecies = GetAllUntransfectedIndecies(txt,'Untransfected'); 
    %%% Get The phasor coordinate for these untransfected samples
    phasor_coordinate_table = cell(length(untransfected_indecies),6); 
    index_count = 1; 

        for u = 1:length(untransfected_indecies)
            index  = untransfected_indecies(u); 
            cell_type = txt(index,3);
            transfection = txt(index,4);
            drug = txt(index,5);
            concentration = txt(index,6);
            donor_only = strcat(path_to_combined_csv,'combined_' ,char(txt(index,1)),num2str(num(index-1,1)),'.csv') ;
            donor_only = char(donor_only); 

            [G,S] = GetPhasorCoordinatesForUntransfected(donor_only,mc3_gradient_slope);
           
            %Put these parameters in the phasor coordinate table
            phasor_coordinate_table{index_count,1} = char(cell_type) ; 
            phasor_coordinate_table{index_count,2} = char(transfection) ; 
            phasor_coordinate_table{index_count,3} = char(drug) ; 
            phasor_coordinate_table{index_count,4} = char(concentration) ; 
            phasor_coordinate_table{index_count,5} = G ; 
            phasor_coordinate_table{index_count,6} = S; 
            index_count = index_count + 1 ; 
        end


    %%% Save phasor coordinates for untrasfected cells to the specified folder
    phasor_results_filename = fullfile(path_to_analysis_folder,'Untransfected_Phasor_Coordinates.xlsx'); 
    xlswrite(phasor_results_filename,phasor_coordinate_table)

    %Estimate Bleed Through parameter using Untransfected well
    bleedthrough_polyfit =[]; 
    unbound_lifetime = 0; 
    cell_type = char(cells{1});
    don_only_index = GetRowFromExcelData(txt,cell_type,'Untransfected','DMSO');
    if(don_only_index > 1)
        donor_only = strcat(path_to_combined_csv,'combined_' ,char(txt(don_only_index,1)),num2str(num(don_only_index-1,1)),'.csv') ;
        donor_only = char(donor_only); 
        if (exist(donor_only,'file') )
           [bleedthrough_polyfit,~,~,unbound_lifetime] = EstimateUntransfectedBleedThroughInSpectralChannelPhasor(donor_only,mc3_gradient_slope); 

        end
    end

    %%% Acceptor shift refers to false negative presence of acceptor molecules from PMT noise
    %%% The untrasnfected data (no acceptor) are used to estimate the apparent presence of acceptor and corrected for
    %%% Expermental condition is defined by the stable and transient cell transfection
    %%% For example mCerulean3-Bcl-XL cell line should have different spectral correction
    %%% incompared to mCerulean3-Bcl-2 cell line
    shift_table = cell(length(untransfected_indecies),6);  

   index_count= 1; 
    for u = 1:length(untransfected_indecies)
            index  = untransfected_indecies(u); 
            cell_type = txt(index,3);
            transfection = txt(index,4);
            drug = txt(index,5);
            concentration = txt(index,6);
            donor_only = strcat(path_to_combined_csv,'combined_' ,char(txt(index,1)),num2str(num(index-1,1)),'.csv') ;
            donor_only = char(donor_only); 


            [G_donor ,S_donor]  = GetPhasorCoordinatesFromTable(phasor_coordinate_table,char(cell_type),'Untransfected',char(drug),char(concentration));

            G_donor = G_donor{1}; 
            S_donor = S_donor{1}; 
            [phasor_shift,ino_shift] = CurveExtractionAndShift(donor_only,bleedthrough_polyfit,G_donor,S_donor,3700,mc3_gradient_slope,ven_gradient_slope,0,true);

            shift_table{index_count,1} = char(cell_type) ; 
            shift_table{index_count,2} = char(transfection) ; 
            shift_table{index_count,3} = char(drug) ; 
            shift_table{index_count,4} = char(concentration) ; 
            shift_table{index_count,5} = phasor_shift ; 
            shift_table{index_count,6} = ino_shift; 


            index_count = index_count + 1 ; 

    end  


    %%%%%%%%% LOOP THROUGH WELL DATA %%%%%%%%%%%%%%%%
    for i = 2:rows
        %if it is not untransfected then find the donor only
        if(isempty(char(txt(i,3))))
            continue;
        end
            cell_type = char(txt(i,3)); %cell line
            transfection  = char(txt(i,4)); % transient transfection
            drug = char(txt(i,5)); %compound name (it could also be DMSO)
            concentration = char(txt(i,6)); % compound concentration in uM

            %Get phasor coordinates for corresponding control well (DMSO no transfection)
            [G_donor ,S_donor]  = GetPhasorCoordinatesFromTable(phasor_coordinate_table,cell_type,'Untransfected',drug,concentration);
             G_donor  = G_donor{1};
             S_donor = S_donor{1}; 
             
             
            [acceptor_shift,~] = GetShiftValuesFromTable(shift_table,cell_type,'Untransfected','DMSO','');
            acceptor_shift = acceptor_shift{1};
            filename = strcat(path_to_combined_csv,'combined_',txt(i,1),num2str(num(i-1,1)),'.csv') ;  
            filename = char(filename);
                if ( exist(filename, 'file'))


                    [~,~] = CurveExtractionAndShift(filename,bleedthrough_polyfit,G_donor,S_donor,unbound_lifetime, mc3_gradient_slope,ven_gradient_slope,acceptor_shift,false);        



                else
                %File does not exist.
                 warningMessage = sprintf('[Warning] file does not exist:\n');
                 donor_only
                 filename
                 continue;
                end


       
    end
  
    disp(['[INFO] Completed Running Step 1 of the Analysis in the following path:',pwd]); 


    end