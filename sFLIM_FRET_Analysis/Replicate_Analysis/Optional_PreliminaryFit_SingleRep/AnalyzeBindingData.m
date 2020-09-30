function [kd, cil,ciu,FitRatio,cum_sum,num_of_ROIs,num_of_binned_points,interpolated_point,max_free_venus,DrugResistance] = AnalyzeBindingData(filename, postive_interpolated_point,negative_interpolated_point,control_ratio,control_satpar)      
%Function used to calculate binding parameters from a binding curve
% Kd, Confidence Interval Upper Bound , Confidence Interval Lower Bound,
% Binding curve Shape Ratio (FitRatio), Num of ROIs contriubting to each binding curve 
% and the interpolated_point = bound fraction at 15 uM of Acceptor added used for calculating resistance

    %%%%%%% USER DEFINED PARAMETERS %%%%%
    max_free_acceptor_concentration = 50;
    shape_ratio_range = 30 ;
    resistance_concentration = 15;% <<< input concentration at which resistance to be calculated

    %%%% ANALYSIS STARTS HERE %%%%%%
    curve_data = csvread(filename,2); 
    b = curve_data(:,1); 
    byy = curve_data(:,2); 
    bey = curve_data(:,3);
    bny = curve_data(:,4);
    b= b(~isnan(byy)); 
    bey = bey(~isnan(byy)); 
    bny = bny(~isnan(byy)); 
    byy = byy(~isnan(byy));
    num_of_ROIs  = sum(bny); 
    max_free_venus = max(b); 
    num_of_binned_points = length(b); 
    
    %%%%%% CHECK 1 number of points and max free venus
    %if there are less than 10 data points, don't bother fitting
    if (max_free_venus < 20 || num_of_binned_points  < 5 )
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
    max_data = mean(iso_byy(end-2:end));
    if(max_data <0.05)
           max_data = 0.05;
    end 

    %make sure that the y_coordinates follow sorted x coordinates for trapzoid integration    
    x = sorted_b ; y = iso_byy; 
    y = y (x<=max_free_acceptor_concentration); 
    x = x (x<=max_free_acceptor_concentration); 
    x(x<0) = 0;
    y(y < 0) = 0; 
    y(y > max_data) = max_data; %data above max data is set to max to minimize noise contribution

    %Area of rectangle spanned by binding curves
    rect = max_data * max(x); 
    %Find Area under the curve
    auc = trapz(x,y);
    %%% calculate binding shape ratio
    FitRatio = auc /(rect-auc);  

    %Cumulative sum under Isotonic fit is always calculated
    cx = x ; cy = y; 
    cy = cy(cx <= shape_ratio_range);
    cx = cx(cx <= shape_ratio_range); 
    cum_sum = trapz(cx, cumsum(cy));
    
   %#DETERMINE DRUG RESISTANCE
   %Resistance concentrtion is always calculated here 15uM     
   %Get the bound fraction at a specified free venus concentration
   
   range = 5;
   
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
      elseif DrugResistance > 100 %% resistance above 100% does not make sense
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
    %construct string from of the equation to pass to MatLab's fit() function
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

