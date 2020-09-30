close all; 
clear all; 
clc; 


%%% paste the directory to your 6_Get_LifetimeUntransfectedControls folder
%%% for each replicate

path_excel1 ='directory\UntransfectedLifetimeFromPhasor.xlsx';
path_excel2 ='directory\UntransfectedLifetimeFromPhasor.xlsx' ;
path_excel3 ='directory\UntransfectedLifetimeFromPhasor.xlsx'; 
path_excel4 ='directory\UntransfectedLifetimeFromPhasor.xlsx' ; 


[n1,wells1]  = xlsread(path_excel1,'Sheet1'); 
% [n1,data1]  = xlsread(path_excel1,'Lifetimes'); 
[rows,cols] = size(wells1);

[n2,wells2]  = xlsread(path_excel2,'Sheet1'); 
% [n2,data2]  = xlsread(path_excel2,'Lifetimes'); 

[n3,wells3]  = xlsread(path_excel3,'Sheet1'); 
% [n3,data3]  = xlsread(path_excel3,'Lifetimes'); 

[n4,wells4]  = xlsread(path_excel4,'Sheet1'); 
% [n4,data4]  = xlsread(path_excel4,'Lifetimes'); 

results{rows,7} = {} ;

figure; hold on;

for i = 2:rows
   cell = char(wells1(i,1)); 
   drug = char(wells1(i,3));
   concentration = char(wells1(i,4)) ;
   
   index_in_sheet2 = GetDrugIndexFromTable(wells2,cell, drug,concentration);
   index_in_sheet3 = GetDrugIndexFromTable(wells3,cell, drug,concentration);
   index_in_sheet4 = GetDrugIndexFromTable(wells4,cell, drug,concentration);

   lifetime1 = n1(i,1); 
   if (index_in_sheet2 ~= -1)
       lifetime2 = n2(index_in_sheet2,1); 
   else
       lifetime2 = NaN; 
       
   end
   
   if (index_in_sheet3 ~= -1)
       lifetime3 = n3(index_in_sheet3,1); 
   else
       lifetime3 = NaN; 
       
   end
   
   
   if (index_in_sheet4 ~= -1)
       lifetime4 = n4(index_in_sheet4,1); 
   else
       lifetime4 = NaN; 
       
   end
   results{i,1} = cell;
   results{i,2} = drug; 
   results{i,3} = concentration; 
   results{i,4} = lifetime1 ;
   results{i,5} = lifetime2 ;
   results{i,6} = lifetime3; 
   results{i,7} = lifetime4; 
    
    comb_lifetimes = [lifetime1, lifetime2, lifetime3, lifetime4]; 
    
    comb_lifetimes = comb_lifetimes(~isnan(comb_lifetimes)); 
    
    plot(ones(size(comb_lifetimes)) * i , comb_lifetimes, 'ko'); 
    
end


newrow = rows; 
%Lets look data in rep2 butnot in rep1 

test2 = ismember(wells2, wells1, 'rows');
idx2 = find(test2(:,4)==0); 
for i = 1:numel(idx2) 
    newrow = newrow+1; 
    
    cell = char(wells2(idx2(i),1)); 
    drug = char(wells2(idx2(i),3));
    concentration = char(wells2(idx2(i),4));
    
    results(newrow,1) ={cell}; 
    results(newrow,2) ={drug}; 
    results(newrow,3) = {concentration}; 
    results(newrow,5) = {n2(idx2(i),1)}; 
    
    
end


test3 = ismember(wells3, wells1, 'rows');
idx3 = find(test3(:,4)==0); 
for i = 1:numel(idx3) 
    newrow = newrow+1; 
    
    cell = char(wells3(idx3(i),1)); 
    drug = char(wells3(idx3(i),3));
    concentration = char(wells3(idx3(i),4));
    
    results(newrow,1) ={cell}; 
    results(newrow,2) ={drug}; 
    results(newrow,3) = {concentration}; 
    results(newrow,5) = {n3(idx3(i),1)}; 
    
    
end


test4 = ismember(wells4, wells1, 'rows');
idx4 = find(test4(:,4)==0); 
for i = 1:numel(idx4) 
    newrow = newrow+1; 
    
    cell = char(wells4(idx4(i),1)); 
    drug = char(wells4(idx4(i),3));
    concentration = char(wells4(idx4(i),4));
    
    results(newrow,1) ={cell}; 
    results(newrow,2) ={drug}; 
    results(newrow,3) = {concentration}; 
    results(newrow,5) = {n4(idx4(i),1)}; 
    
end




xlswrite('CombinedReplicatesLifetimeAnalysis.xls',results); 


disp('hello');











