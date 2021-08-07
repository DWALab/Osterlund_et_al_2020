function well_position = GetWellPositionInTable(table,cell,transfection,drug,concentration)
%%% Function used to get row index of a specific well fomr the excel sheet
%%% given, cell ine, transfection, drug, and drug concentration
%%% if value not found -1 is return 
    [rows,~] = size(table);
    for i = 1:rows
        row_cell = char(table{i,3}) ; 
        row_transfection = char(table{i,4});
        row_drug = char(table{i,5}) ; 
        row_concentration = char(table{i,6});
        
        if(strcmp(row_cell,cell) && strcmp(row_transfection,transfection)&& strcmp(row_drug,drug) && strcmp(row_concentration,concentration) )
            well_position = i;
            return;
        end
    end
    well_position = -1;
end