function interpolated_point = FindInterpolatedPoint(filename)
%%% Function used to determine bound fraction at a specific concentration in binding curves
%%% Since the generated binned curves are not continuously sampled, interpolation is used to examine
%%% bound fraction at specified concentration (here we are intrested in bound fraction at 15uM free acceptor) 
    

    %%%% User Defined Paramaeters %%%%%%
    resistance_concentration = 15;% <<< input concentration2
    range = 5; % +/- range in case binned data don't exist near specified concentration


    %%% ANALYSIS STARTS HERE %%%%%
    curve_data = csvread(filename,2); 
    b = curve_data(:,1); 
    byy = curve_data(:,2); 
    bey = curve_data(:,3);
    bny = curve_data(:,4);
    b= b(~isnan(byy)); 
    bey = bey(~isnan(byy)); 
    byy = byy(~isnan(byy));
    [sorted_b, Idx ] = sort(b);
    sorted_byy = byy(Idx);
    iso_byy = lsqisotonic(sorted_b,sorted_byy);
    
    
    interpolated_point = NaN;
   
    lower_idx = find(sorted_b < resistance_concentration + range); 
    upper_idx = find(sorted_b > resistance_concentration - range); 
    interpolated_point = NaN;
   
   if isempty(upper_idx) || isempty(lower_idx)
       interpolated_point = NaN;
       return       
   end
   
   if ~isempty(lower_idx) && ~isempty(upper_idx) 
       interpolated_point = median([iso_byy(lower_idx(end)),iso_byy(upper_idx(1))]); 
       if interpolated_point < 0 
           interpolated_point = 0; 
       end
   end    
   
   
end