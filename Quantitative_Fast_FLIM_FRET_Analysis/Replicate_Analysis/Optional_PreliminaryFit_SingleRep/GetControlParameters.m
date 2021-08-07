function [postive_interpolated_point,negative_interpolated_point,fit_ratio,saturation_parameter] = GetControlParameters(table,cell,transfection)
%%% Functions used to extract control conditions from excel sheet
%%% the table of information is passed along with cell line and transfection
[rows,~] = size(table);
for i = 1:rows
    row_cell = char(table{i,1}) ; 
    pos_transfection = char(table{i,2});
    neg_transfection = char(table{i,4}); 
    %if cell type found AND (positive OR negtive control found) then use
    %parameters
    if(strcmp(row_cell,cell) && (strcmp(pos_transfection,transfection) || strcmp(neg_transfection,transfection)))
        postive_interpolated_point = table{i,6};
        negative_interpolated_point = table{i,7};  
        fit_ratio = table{i,8} ; 
        saturation_parameter = table{i,9}; 
        return;
    end
end
 disp('[WARNING] Control Not Found For:');
 disp([cell, transfection]);
 postive_interpolated_point = NaN;
 negative_interpolated_point = NaN;  
 fit_ratio = NaN ;
 saturation_parameter = NaN;
 
end