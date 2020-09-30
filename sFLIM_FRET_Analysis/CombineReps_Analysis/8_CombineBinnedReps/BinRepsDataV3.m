
function [bin_center, bin_y, bin_y_std_err, ]  = BinRepsDataV2(x,y,bins)
% New Rep Averaging Code
% Only averages if there is more than one data points
% bin_std_err is now calculated
    bin_center= []; 
    bin_y = [] ; 
    bin_y_stderr = []; 

    index = 1; 
    for i = 2:length(bins)
        lower = bins(i-1);
        upper = bins(i);
    
        elements = find(x > lower & x <= upper);
        if (length(elements) > 1)
            x_elements = x(elements); 
            y_elements = y(elements); 
            
            bin_center(1,index) = mean(x_elements);
            
            bin_y(1,index) = mean(y_elements); 
            
            bin_y_std_err(1,index) = std(y_elements)/sqrt(length(elements));
            index = index + 1;
        end        
        
    end
end