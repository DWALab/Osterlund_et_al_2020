%Main function used to calculate binding parameters from a binding curve
%Kd, ConfInterval Upper, ConfInterval Lower, Fit Ratio, Num of ROIs
%Analyzed, interpolated_point = bound fraction at 15 uM of Acceptor added
%Nehad Hirmiz
%Created on 20190806

function [kd, cil,ciu,Ratio,cum_sum,num_of_ROIs,interpolated_point,interpolated_point2,max_free_venus] = FitReps(filename, saturation_parameter,control_ratio)
    


    curve_data = csvread(filename,2); 
    
    b = curve_data(:,1); 
    byy = curve_data(:,2); 
    bey = curve_data(:,3);
    bny = curve_data(:,4);
    b= b(~isnan(byy)); 
    bey = bey(~isnan(byy)); 
    byy = byy(~isnan(byy));
%      bny = bny(~innan(bny));
     
    num_of_ROIs  = sum(bny); 
    saturation_parameter_str = num2str(saturation_parameter); 
    max_free_venus = max(b); 
   
    %if there are less than 10 data points, don't bother fitting
%     if length(byy) < 10
%         kd = NaN; 
%         cil = NaN; 
%         ciu = NaN; 
%         Ratio = NaN;
%         cum_sum = NaN;
%         interpolated_point =NaN; 
%         
%         return 
%     end   
    
    %Let use the Least Squre Isotonic fit to get the ratio and the
    %resistance point 
    

   [sorted_b, Idx ] = sort(b);
    sorted_byy = byy(Idx);
    iso_byy = lsqisotonic(sorted_b,sorted_byy);
                      
    max_data = median(iso_byy(end-6:end));
                           
                  

    x = sorted_b ; y = iso_byy; 
    y = y (x<=50); 
    x = x (x<=50); 
    x(x<0) = 0;
    y(y < 0) = 0; 

    x(y > max_data) = [];
    y(y > max_data) =  [];

    
    % Cumulative sum under Isotonic fit is always calculated
%     cx = x ; cy = y; 
%     cy = cy(cx <=30);
%     cx = cx(cx <=30); 
%     cum_sum = trapz(cx, cumsum(cy));
    
    X=[x y]; 
    [coef,~,~] = pca(X);
    cum_sum = coef(2,1);
    
   %Resistance concentrtion is always calculated here 10uM     
   %Get the bound fraction at a specified free venus concentration
   resistance_concentration = 10;% <<< input concentration
   resistance_concentration2 = 20;% <<< input concentration2
   
    lower_idx = find(sorted_b < resistance_concentration); 
    upper_idx = find(sorted_b > resistance_concentration); 
    interpolated_point = NaN;
   
    lower_idx2 = find(sorted_b < resistance_concentration2); 
    upper_idx2 = find(sorted_b > resistance_concentration2); 
    interpolated_point2 = NaN;
   
   if isempty(upper_idx) || isempty(lower_idx)
       interpolated_point = NaN;
       
   end
   
   if ~isempty(lower_idx) && ~isempty(upper_idx) 
       interpolated_point = median([iso_byy(lower_idx(end)),iso_byy(upper_idx(1))]); 
       if interpolated_point < 0 
           interpolated_point = 0; 
       end
   end    


       if isempty(upper_idx2) || isempty(lower_idx2)
           interpolated_point2 = NaN;

       end
       if ~isempty(lower_idx2) && ~isempty(upper_idx2) 
           interpolated_point2 = median([iso_byy(lower_idx2(end)),iso_byy(upper_idx2(1))]); 
           if interpolated_point2 < 0 
               interpolated_point2 = 0; 
           end
       
       end
   
    if(max_data <0.065)
        max_data = 0.065;
    end
        
    

    
    rect = max_data * max(x); 
    auc = trapz(x,y); 
    Ratio = auc / (rect - auc); 
    
    
    
   if saturation_parameter < 0.065
%        Ratio = NaN; 
       kd = NaN; 
       cil = NaN;
       ciu = NaN;
       %exit function since you should not need to fit data
       return;
   end 
    
   %Let's check on control ratio before determining the data ratio
   if(isnan(control_ratio) || control_ratio < 2)
   
       kd = NaN; 
       cil = NaN;
       ciu = NaN;
       %exit function since you should not need to fit data
       return;
   end
    

    
    %Now that both condition num of poins and the ratio > 2
    % are met 
    % then we can get the binding by fitting the data to a curve
    
    kd_2d_equation = strcat(saturation_parameter_str,'*x/(kd + x)');
    try
       b(b<0) =0;
       f = fit(b,byy,kd_2d_equation,'StartPoint',[1],'MaxIter',1000,'TolFun',1e-4) ;
       x = min(b):0.01:max(b);   
       kd = f.kd;
       ci  = confint(f); 
       cil = ci(1); 
       ciu = ci(2); 

        
              
    catch exception
        %Return NaN if the fitting does not work
        kd = NaN;
        cil = NaN ; 
        ciu = NaN; 
        return
    end
    
    
    range = max(b);
    num_of_binned_points = length(b); 
    if (range < 15 || num_of_binned_points  < 10 )
        kd = NaN;
        cil = NaN;
        ciu = NaN;
        interpolated_point = NaN; 
        interpolated_point2 = NaN; 
        Ratio= NaN;
        cum_sum = NaN;
        return 
    end


end

