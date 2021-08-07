function [x,y,dy,xx2,inbetween, c1,c2] = FitAndGetConfInterval(filename, saturation,fit_ratio)

data = csvread(filename,2); 

x = data(:,1); 
y = data(:,2); 
dy = data(:,4); 


x(isnan(y)) = []; 
dy(isnan(y)) = []; 
y(isnan(y)) = []; 
if length(y)<10 || max(x)<15 || fit_ratio < 2 || isnan(fit_ratio)
    xx2=0;
    inbetween = 0;
    c1 = zeros(size(x)); 
    c2 = zeros(size(x));
    
    
    return;
end


fit_equation  = strcat('(',num2str(saturation),'* x) / (kd + x)'); 
    try
        x(x<0) = 0 ;
        f = fit(x,y,fit_equation, 'Lower',[0],'StartPoint',[1],'MaxIter',5000,'TolFun',1e-4);
        conf_int = confint(f); 
        xx = -0.0001:50; 

        c1 = saturation * xx ./ (conf_int(1) + xx);
        c2 = saturation * xx ./ (conf_int(2) + xx);
        xx2 = [xx fliplr(xx)] ;
        inbetween = [c1, fliplr(c2)] ;
        
        if(conf_int(1) == Inf) || (conf_int(1) == -Inf )
            xx2 = zeros(size(x)); 
            inbetween = zeros(size(x)); 
            c1 = zeros(size(x)); 
            c2 = zeros(size(x)); 
            return ;
        end
    catch
        xx2 = zeros(size(x)); 
        inbetween = zeros(size(x)); 
        c1 = zeros(size(x)); 
        c2 = zeros(size(x)); 
        
        
        
    end
end
