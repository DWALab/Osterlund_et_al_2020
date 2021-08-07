%Method used to extract Global Phasor Coordinate for untransfected cells
%files
%Nehad Hirmiz
%Created on 20190806

function [G_untransfected,S_untransfected] = GetPhasorCoordinatesForUntransfected(filename,mc3_gradient_slope)
%%%% Bleed Through Factors %%%%
    %%CSV Columns Indecis
     %%%% Phasor constants
    freq0 = 30.51757e6;
    harmonic = 1;
    freq = harmonic * freq0;        % virtual frequency for higher harmonics
    w = 2 * pi * freq ;
    
    %%CSV Columns Indecis
    sep = ','; %CSV files are separated by commas
    quote = '"';
    photon_counts_col = 16;
    tcspc_start_col = 19;
    tcspc_end_col = 19 + 400;
    %Get lifetime decays for all ROIs
    col_offset = 43;
    bound_fraction_col = 11;
    tau1_col = 12; 
    tau2_col = 13; 
    chi_col = 14; 
    
    area_col = 17; 
   
    

    %Read CSV file using swallow_csv (C++ code compiled to process .CSV files)
    % n is the matrix containing numerical data
    % t is the matrix containing text data
    [n , ~] = swallow_csv(filename, quote, sep);


    
    mc3_photon_counts = n(:,photon_counts_col);
    mc3_T0  = sum(n(:,tcspc_start_col + 42:tcspc_start_col + 44),2); 
    roi_area = n(:,area_col); 



    % Filter using mCerulean3 Photoncounts
    mc3_photon_counts = mc3_photon_counts ./ roi_area;  
    good_rois  = find(mc3_photon_counts > 6 & mc3_photon_counts < 500); 
    mc3_photon_counts = mc3_photon_counts(good_rois); 
    %Get Decays for these ROIs 
    roi_decays = n(good_rois,tcspc_start_col + col_offset: tcspc_end_col);
    mc3_T0 = mc3_T0(good_rois);
    roi_area = roi_area(good_rois); 
    
    %Remove data for ROIs with photon counts below desired counts

    [G_donor, S_donor] = CalculatePhasorGSForDecayMatrix(roi_decays);
    
    mc3_T0  = mc3_T0 ./ roi_area;

    mc3_concentration = (mc3_gradient_slope * mc3_T0);
    
    good_mc3_concentration = find(mc3_concentration > 1.0 & mc3_concentration < 5.0 );
    
    
    G_donor = G_donor(1,good_mc3_concentration);
    S_donor = S_donor(1,good_mc3_concentration);
    
    
    G_untransfected = mean(G_donor);
    S_untransfected = mean(S_donor); 
end

