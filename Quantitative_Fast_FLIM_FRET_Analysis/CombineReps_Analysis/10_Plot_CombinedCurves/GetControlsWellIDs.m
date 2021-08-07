function [pos_control, pos_well_id,neg_control, neg_well_id,saturation_parameter,fit_ratio] = GetControlsWellIDs(table,cell,transfection)
[rows,~] = size(table);
for i = 1:rows
    row_cell = char(table{i,1}) ; 
    row_transfection = char(table{i,2});
    
    if(strcmp(row_cell,cell) && strcmp(row_transfection,transfection))
        pos_control = char(table{i,2}); 
        pos_well_id = char(table{i,3});
        neg_well_id = char(table{i,5}); 
        neg_control = char(table{i,4}); 
        saturation_parameter = table{i,6};  
        fit_ratio = table{i,7} ; 
        return;
    end
end
 pos_well_id = 'NotFound';
 neg_well_id = 'NotFound';
 pos_control = 'NotFound';
 neg_control = 'NotFound';
 saturation_parameter=-1;
 fit_ratio = -1;
end