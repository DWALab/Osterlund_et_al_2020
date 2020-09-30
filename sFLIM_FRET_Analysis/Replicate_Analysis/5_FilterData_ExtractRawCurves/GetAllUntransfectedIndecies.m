function untransfected_indecies = GetAllUntransfectedIndecies(data,transfection)
%% Function used to extracted index of transfected data from plate map
    [rows,~] = size(data);
        untransfected_indecies  = [] ;
        count=  1;  
        for i = 1:rows
                        if( strcmp(data(i,4),transfection))
                            untransfected_indecies(count) = i ;
                            count = count + 1;
                        end
        end       
end