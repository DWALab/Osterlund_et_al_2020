function rowindex = GetRowFromExcelData(data,cell,transfection,drug)
% Function used to identify the row index in the plate map
%given informatoin about the well
% if the index is not found a -1 is returned
    [rows,cols] = size(data);
    for i = 1:rows
        if(strcmp(data(i,3),cell) && strcmp(data(i,4),transfection) && strcmp(data(i,5),drug))
            rowindex = i;
            return;
        end
    end
    rowindex = -1;
end