function [kd, cil,ciu,FitRatio,cum_sum,num_of_ROIs,num_of_binned_points,interpolated_point,max_free_venus,DrugResistance] = AnalyzeBindingData(filename, postive_interpolated_point,negative_interpolated_point,control_ratio,control_satpar)      
% Function used to calculate binding parameters from a binding curve
% Kd, ConfInterval Upper, ConfInterval Lower, Fit Ratio, Num of ROIs
% Analyzed, interpolated_point = bound fraction at 15 uM of Acceptor added
% Nehad Hirmiz
    

    %%%%%% USER DEFINED PARAMETERS %%%%%
    analyzable_free_acceptor_range = 20;
    num_of_binned_points_threhsold = 15;
    shape_ratio_range = 50; % uM
    cumulate_area_range = 30; % uM
    %#DETERMINE DRUG RESISTANCE
   %Resistance concentrtion is always calculated here 15uM     
   %Get the bound fraction at a specified free venus concentration
   resistance_concentration = 15;% <<< input concentration
   range = 5; % +/- range in case there are not points at 15uM

    curve_data = csvread(filename,2); 
    b = curve_data(:,1); 
    byy = curve_data(:,2); 
    bey = curve_data(:,3);
    bny = curve_data(:,4);
    b= b(~isnan(byy)); 
    byy = byy(~isnan(byy));
    num_of_ROIs  = sum(bny); 
    max_free_venus = max(b); 
    num_of_binned_points = length(b); 
    
    
    %%%%%% CHECK 1 number of points and max free venus
    %if there are less than 10 data points, don't bother fitting
    if (max_free_venus < analyzable_free_acceptor_range || num_of_binned_points  < num_of_binned_points_threhsold )
        kd = NaN;
        cil = NaN;
        ciu = NaN;
        interpolated_point = NaN; 
     
        FitRatio= NaN;
        cum_sum = NaN;
        DrugResistance = NaN;
        return 
    end   
    
    %Let use the Least Squre Isotonic fit to get the ratio and the
    %resistance point 
   

   [sorted_b, Idx ] = sort(b);
    sorted_byy = byy(Idx);
    iso_byy = lsqisotonic(sorted_b,sorted_byy);               
    max_data = median(iso_byy(end-6:end));
                           
    
    if(max_data <0.05)
           max_data = 0.05;
    end 

        
     x = sorted_b ; y = iso_byy; 
    y = y (x<=shape_ratio_range); 
    x = x (x<=shape_ratio_range); 
    x(x<0) = 0;
    y(y < 0) = 0; 
    x(y > max_data) = [];
    y(y > max_data) =  [];

    rect = max_data * max(x); 
    auc = trapz(x,y);
    FitRatio = auc /(rect-auc);  

    %Cumulative sum under Isotonic fit is always calculated
    cx = x ; cy = y; 
    cy = cy(cx <=cumulate_area_range);
    cx = cx(cx <=cumulate_area_range); 
    cum_sum = trapz(cx, cumsum(cy));
    

    
    

   
    lower_idx = find(sorted_b < resistance_concentration + range ); 
    upper_idx = find(sorted_b > resistance_concentration - range); 
    interpolated_point = NaN;
   
   if isempty(upper_idx) || isempty(lower_idx)
       interpolated_point = NaN;
       
   end
   
   if ~isempty(lower_idx) && ~isempty(upper_idx) 
       interpolated_point = median([iso_byy(lower_idx(end)),iso_byy(upper_idx(1))]); 
       if interpolated_point < 0 
           interpolated_point = 0; 
       end
   end    

   %Let's Caclulate Resistance
   interpolated_points_difference = postive_interpolated_point - negative_interpolated_point;
   if (interpolated_points_difference > 0.05) && ~isnan(interpolated_point)
      DrugResistance = ((interpolated_point - negative_interpolated_point)/interpolated_points_difference)*100;
      if DrugResistance < 0
          DrugResistance = 0;
      elseif DrugResistance > 100
          DrugResistance = 100;
      end
   else
       DrugResistance = NaN; 
   end
       
    
%     disp([interpolated_points_difference, control_ratio])
    if interpolated_points_difference <0.05 || control_ratio < 2
        kd =NaN;
        cil = NaN;
        ciu = NaN;
        return 
    end
    
    %Now that both condition num of poins and the ratio > 2
    % are met 
    % then we can get the binding by fitting the data to a curve
    saturation_parameter_str = num2str(control_satpar); 
    %construct equation string to pass to fit() function in matlab
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


end

