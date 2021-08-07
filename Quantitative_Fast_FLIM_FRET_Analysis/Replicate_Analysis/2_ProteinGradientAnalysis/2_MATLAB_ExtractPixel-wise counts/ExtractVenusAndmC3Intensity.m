function [mc3_T0,ven_spec_intensity] = ExtractVenusAndmC3Intensity(filename)
filename
%%INO Microscope Parameters
freq0 = 30.51757e6;
% delta_t = 6.4e-11;           % width of one time channel
harmonic = 1;
freq = harmonic * freq0;        % virtual frequency for higher harmonics
w = 2 * pi * freq ;

%%CSV Columns Indecis
sep = ','; %CSV files are separated by commas
quote = '"';
photon_counts_col = 16;
tcspc_start_col = 19;
tcspc_end_col = 19 + 400;
%Get lifetie decays for all ROIs
col_offset = 43;

min_photon_counts = 0;
%Read CSV file using swallow_csv (C++ code compiled to process .CSV files)
% n is the matrix containing numerical data
% t is the matrix containing text data
 [n , t] = swallow_csv(filename, quote, sep);
 mc3_photon_counts = n(:,photon_counts_col);
 mc3_T0  = sum(n(:, tcspc_start_col + 42:tcspc_start_col + 44),2); 
 ven_spec_intensity = squeeze(n(:,1632));
 roi_area = n(:,17); 
good_rois  = find(mc3_photon_counts > min_photon_counts); 
mc3_photon_counts = mc3_photon_counts(good_rois); 
ven_spec_intensity = ven_spec_intensity(good_rois); 
roi_area = roi_area(good_rois); 
mc3_T0  = mc3_T0(good_rois); 
ven_spec_intensity = ven_spec_intensity ./ roi_area; 
% mc3_photon_counts = mc3_photon_counts ./ roi_area; 
mc3_T0  = mc3_T0 ./ roi_area;

end

