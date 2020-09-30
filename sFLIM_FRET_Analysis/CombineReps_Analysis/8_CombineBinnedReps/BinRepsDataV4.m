function binned_data  = BinRepsDataV4(data,bins)
% New Rep Averaging Code
% Only averages if there is more than one data points
% bin_std_err is now calculated

    fa = data(:,1);
    bf =data(:,2); 
    num_of_points = data(:,4); 
    stddev_fa = data(:,5); 
    stddev_bf = data(:,6); 



     bin_center = []; 
     bin_y = [] ;  
     bin_std_fa = [];
     bin_std_bf = [] ;
     sum_num_points = []; 
     num_of_rep_points = []  ;
     rep_bf_stError = [] ;
     rep_FA_stError = [] ;
     rep_FA_var = [];
     rep_bf_var = [];

    index = 1; 
    for i = 2:length(bins)
        lower = bins(i-1);
        upper = bins(i);

        elements = find(fa > lower & fa <= upper);
        if (length(elements) > 1)
            %from each column get data belonging to the same bin
            bin_fa = fa(elements); 
            bin_bf = bf(elements); 
            bin_stddev_fa = stddev_fa(elements); 
            bin_stddev_bf = stddev_bf(elements); 
            
            mean_bf = mean(bin_bf) ;
            mean_fa = mean(bin_fa); 
            n = num_of_points(elements); 
            s_fa = stddev_fa(elements); 
            s_bf = stddev_bf(elements); 
            
            sum_num_points(1,index) = sum(n); 
            num_of_rep_points(1,index) = length(elements); 

            %free acceptor
            bin_center(1,index) = mean_fa;
            bin_std_fa(1,index) = std(bin_fa); 
           
            %bound fraction
            bin_y(1,index) = mean_bf; 
            bin_std_bf(1,index) = std(bin_bf); 
            
            dist_fa = mean_fa - bin_fa;
            dist_bf = mean_bf - bin_bf ;
            
            rep_FA_var(1,index)=  sqrt((sum(n.* s_fa .* s_fa) + sum(n.*dist_fa.*dist_fa))/sum(n) );
            rep_bf_var(1,index) = sqrt((sum(n.* s_bf .* s_bf) + sum(n.*dist_bf.*dist_bf))/sum(n) );
 
            rep_bf_stError(1,index) = (std(bin_bf))/sqrt(length(elements)); 
            rep_FA_stError(1,index) = (std(bin_fa))/sqrt(length(elements)); 
            
            index = index + 1;

        end        

    end
    
    %combine_results_into a single array and return 
    binned_data = [bin_center' bin_y' bin_std_fa' bin_std_bf' sum_num_points' num_of_rep_points' rep_bf_stError' rep_FA_stError' rep_FA_var' rep_bf_var']; 
    
    
end