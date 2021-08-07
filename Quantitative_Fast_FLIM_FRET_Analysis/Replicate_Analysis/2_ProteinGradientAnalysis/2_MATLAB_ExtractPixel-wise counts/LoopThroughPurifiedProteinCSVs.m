clear all; close all; clc; 
path = 'Directory\' ;
file_list = getAllFiles(path,'*.CSV', false); 
mc3_T0_vals = zeros(length(file_list)*4,1);
ven_int_vals = zeros(length(file_list)*4,1);
well_names =file_list;
for i = 1:length(file_list)
  filename = strcat(path,char(file_list(i)));
  [mc3_T0 , ven_intensity] = ExtractVenusAndmC3Intensity(filename); 
  begin_index = i * 4 - 3;
  end_index = i*4 ;
  mc3_T0_vals(begin_index:end_index, 1) = mc3_T0;
  ven_int_vals(begin_index:end_index, 1) = ven_intensity; 
  for j = begin_index:end_index
    x = char(file_list(i)); 
    well_names(j) = cellstr(x(1:10));
  end
  
end

output_filename = strcat(path,'combinedGradient_Results.xls') ;
M = [well_names num2cell(mc3_T0_vals) num2cell(ven_int_vals)];
    
xlswrite(output_filename , M);
