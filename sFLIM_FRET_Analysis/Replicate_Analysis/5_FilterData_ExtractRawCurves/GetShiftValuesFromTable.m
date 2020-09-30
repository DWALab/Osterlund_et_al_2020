function [G,S] = GetShiftValuesFromTable(data,cell_type,transfection,drug ,concentration)
%Function used to return phasor coordiantes
%For wells where no transfection or untreated but with compound/drug added
% this useful to determine if the druf effects the donor lifetime
% if the phasor coordinates are not found then zeros are returned

    G = 0;
    S = 0;

    [rows,~] = size(data);
    %if the transfection is DMSO (buffer only) then no need to check
    %concentration
    if strcmp(drug,'untreated')
    drug = 'DMSO'; 
    end
    if strcmp(drug,'DMSO')
        concentration = 'None';
    end

    %for untransfected cells there is no drug, no concentration
    if strcmp(concentration,'None')
        for i = 1:rows
            if( strcmp(char(data{i,1}),cell_type) && strcmp(char(data{i,2}),transfection) && strcmp(char(data{i,3}),drug))
                G = data(i,5) ;
                S = data(i,6); 
                return
            end
        end
    else
    
    
   
        c_num = strsplit(concentration,'u'); 
        current_concentration = str2num(c_num{1});
        concentration_array =[];
        concentration_indecies =[];
        concentration_count = 1; 
        for i = 1:rows
            if( strcmp(char(data{i,1}),cell_type) && strcmp(char(data{i,2}),transfection) && strcmp(char(data{i,3}),drug))
                c_str = char(data(i,4)); 
                c_num = strsplit(c_str,'u'); 
                concentration_array(concentration_count) = str2num(c_num{1}); 
                concentration_indecies(concentration_count) = i; 
                concentration_count = concentration_count + 1; 
            end
        end
  
        %Let's check if one of the concentrations matches the 
            %If concentration exist then use the phasor coordinate
            c_index = find(concentration_array == current_concentration);
            if(c_index)
                G = data(concentration_indecies(c_index),5);
                S = data(concentration_indecies(c_index),6);
                return
            %If it does not exist then choose larger drug concentration
            else
                c_index = find(concentration_array > current_concentration);
                if(c_index)
                    sub_concentration_array = concentration_array(c_index); 
                    [val,~] = min(sub_concentration_array); 
                
                
                    c_index = find(concentration_array == val); 
                
                
                    G = data(concentration_indecies(c_index),5);
                    S = data(concentration_indecies(c_index),6);
                    return
                else
                    val = max(concentration_array); 
                    c_index = find(concentration_array == val); 
                    G = data(concentration_indecies(c_index),5);
                    S = data(concentration_indecies(c_index),6);
                    return                
                
                end
                
            end
        
    end     

end