function saturation_parameter = GetSaturationParameter(table,satnum,cell,transfection,drug)
[rows,~] = size(table);
for i = 1:rows
    row_cell = char(table{i,1}) ; 
    row_transfection = char(table{i,2});
    row_drug = char(table{i,3}) ; 
    
    if(strcmp(row_cell,cell) && strcmp(row_transfection,transfection)&& strcmp(row_drug,drug) )
        saturation_parameter = satnum(i-1,1);
        return;
    end
end
 saturation_parameter = -1;
end