function [saturation_parameter,ratio] = GetSaturationParameterFromTable(table,cell,transfection)
%%%%% Given Control Table indicating Cell and Transfection
%%% Find the satruatoin parameter and the fit ratio for that experiment
%%% If Not found, then return -1 for both values

    [rows,~] = size(table);
for i = 1:rows
    row_cell = char(table{i,1}) ; 
    row_transfection = char(table{i,2}(1:5));
    if(strcmp(row_cell,cell) && strcmp(row_transfection,transfection(1:5)) )
        saturation_parameter = (table{i,4});
        ratio =  (table{i,5});
        return;
    end
end
 saturation_parameter = -1;
 ratio = -1 ;
end