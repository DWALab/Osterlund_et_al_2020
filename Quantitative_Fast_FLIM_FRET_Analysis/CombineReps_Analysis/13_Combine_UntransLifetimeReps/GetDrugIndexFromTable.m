function index = GetDrugIndexFromTable(table,cell, drug,concentration)
[rows,cols] = size(table);
for i = 1:rows
    row_cell = char(table{i,1}); 
    row_drug = char(table{i,3}) ; 
    row_concentration = char(table{i,4});
    if(strcmp(drug,'DMSO'))
        concentration = '0';
        row_concentration = '0'; 
    end
    
    if(strcmp(row_cell,cell) && strcmp(row_drug,drug) && strcmp(row_concentration,concentration) )
        index = i;
        return;
    end
end
 index = -1;
end