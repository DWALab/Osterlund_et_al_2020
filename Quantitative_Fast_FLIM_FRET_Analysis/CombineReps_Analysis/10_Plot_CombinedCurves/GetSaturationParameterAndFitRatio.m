function [saturation_parameter,fit_ratio] = GetSaturationParameterAndFitRatio(table,satnum,cell,transfection,drug)
[rows,~] = size(table);
for i = 1:rows
    row_cell = char(table{i,1}) ; 
    row_transfection = char(table{i,2});
    row_drug = char(table{i,3}) ; 
    
    if(strcmp(row_cell,cell) && strcmp(row_transfection,transfection) )
        saturation_parameter = satnum(i-1,4);
        fit_ratio = satnum(i-1,3); 
        return;
    end
end
 saturation_parameter = -1;
 fit_ratio = -1; 
end