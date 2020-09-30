function rowindex = GetRowFromExcelData(data,cell,transfection,drug, concentration)
[rows,cols] = size(data);
for i = 1:rows
    if(strcmp(data(i,3),cell) && strcmp(data(i,4),transfection) && strcmp(data(i,5),drug) && strcmp(data(i,6),concentration))
        rowindex = i;
        return;
    end
end
 rowindex = -1;
end