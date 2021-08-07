% Open plate maps using a GUI interface

clear all; 
close all; 
clc; 
%Path to combined binned data
path_to_binned_reps = 'directory\';  
%Path to combined binned saturation parameter
satpath ='directory\'; 
satfile = 'SatParameters_CombinedBinnedReps.xlsx'; 
sat_path = fullfile(satpath,satfile); 
[satnum , sattxt] = xlsread(sat_path); 

%Path to platemap
excel_file = 'directory\MasterPlatemap.xlsx';
excel_sheet ='Rep1';

%Path to output plotted figures
path_to_final_graphs = 'directory\';     

[num ,txt] = xlsread(excel_file,excel_sheet); 
[rows,cols]  = size(txt);


%Read the saturation table information for the positive controls
[satnum , sattxt] = xlsread(sat_path); 

cells = {{'CellName1'},{'CellName2'}}; 
transfection_references = {{'Transfection1'},{'Transfection2'},{'Transfection3'},{'Transfection4'},{'Transfection5'}};
negative_references = {{'Neg Control1'},{'Neg Control2'},{'Neg Control3'},{'Neg Control4'},{'Neg Control5'}};

% % 
control_table = cell(length(transfection_references)*length(cells)+1,7);
control_index=1;
for c = 1:length(cells)
    for t = 1:length(transfection_references)
    cell = cells{c}; 
    positive_control = transfection_references{t};
    negative_control = negative_references{t}; 
    %disp([cell,positive_control, negative_control]);
    positive_control_index =  GetWellPositionInTable(txt,cell,positive_control,'DMSO','');
    negative_control_index =  GetWellPositionInTable(txt,cell,negative_control,'DMSO','');
   
    if positive_control_index < 1 || negative_control_index < 1
        continue;
    end
    
    if(positive_control_index > 0) && (negative_control_index > 0 ) 
    
        positive_wellid = strcat(char(txt(positive_control_index)), num2str(num(positive_control_index - 1,1))); 
        negative_wellid = strcat(char(txt(negative_control_index)), num2str(num(negative_control_index - 1,1))); 
        [sat_parameter,fit_ratio] =  GetSaturationParameterAndFitRatio(sattxt,satnum,cell,positive_control,'DMSO'); 
        
        control_table(control_index,1) = cell; 
        control_table(control_index,2) = positive_control; 
        control_table(control_index,3) = {positive_wellid}; 
        control_table(control_index,4) = negative_control; 
        control_table(control_index,5) = {negative_wellid}; 
        control_table(control_index,6) = {sat_parameter};
        control_table(control_index,7) = {fit_ratio}; 
    else
        positive_wellid = strcat(char(txt(positive_control_index)), num2str(num(positive_control_index - 1,1))); 
        negative_wellid = strcat(char(txt(negative_control_index)), num2str(num(negative_control_index - 1,1))); 
        [sat_parameter,fit_ratio] =  GetSaturationParameterAndFitRatio(sattxt,satnum,cell,positive_control,'DMSO'); 
        
        control_table(control_index,1) = cell; 
        control_table(control_index,2) = {positive_control}; 
        control_table(control_index,3) = {'NotFound'}; 
        control_table(control_index,4) = {negative_control}; 
        control_table(control_index,5) = {'NotFound'}; 
        control_table(control_index,6) = {sat_parameter};
        control_table(control_index,7) = {fit_ratio};
    
    end
    %update index
    control_index = control_index + 1; 
    
    end
    
    
end




%Colors for plotting 
gray_color =[0.5 0.5 0.5]; 
blue_color=[0 0 1];
cyan_color=[0.3010 0.7450 0.9330];
orange_color=[1, 0.48, 0.3];


for i = 2:rows
 celltype = txt(i,3);
 transfection = txt(i,4);
 drug = txt(i,5);
 concentration = txt(i,6);
%  if (strcmp(drug,'DMSO'))
%      
%     continue; 
%  end
 [positive_control, positive_well_id,negative_control,negative_well_id,saturation_parameter,fit_ratio] = GetControlsWellIDs(control_table,celltype,transfection); 
 if(strcmp(positive_well_id,'NotFound'))
     disp(['Control Not Found. Skipping Control Plotting for:']); 
     disp(transfection);
 else
     positive_cont_filename =  strcat('combined_',positive_well_id,'_binnedReps.csv'); 
     pos_cont_path = fullfile(path_to_binned_reps,positive_cont_filename); 
     negative_cont_filename =  strcat('combined_',negative_well_id,'_binnedReps.csv');
     neg_cont_path = fullfile(path_to_binned_reps,negative_cont_filename); 
     
     
     current_well_id = strcat(char(txt(i,1)),num2str(num(i-1,1)));
     current_filename =  strcat('combined_',current_well_id,'_binnedReps.csv');
     current_path = fullfile(path_to_binned_reps,current_filename); 
     
  
     [px,py,pdy,pxx,pinbetween,pc1,pc2] = FitAndGetConfInterval(pos_cont_path,saturation_parameter,fit_ratio); 
     [nx,ny,ndy,nxx,ninbetween,nc1,nc2] = FitAndGetConfInterval(neg_cont_path,saturation_parameter,fit_ratio); 
     [x1,y1,dy1,xx1,inbetween1,xc1,xc2] = FitAndGetConfInterval(current_path,saturation_parameter,fit_ratio); 
     
     
     
     plot_fname = strcat(current_well_id,'_',char(txt(i,3)),'_',char(txt(i,4)),'_',char(txt(i,5)),'_',char(txt(i,6)) );
        if contains(plot_fname, '.')
           plot_fname = strrep(plot_fname,'.','-');
        end
     plot_path = fullfile(path_to_final_graphs,plot_fname); 
     
     hold on; 
         
        
      
        fill(pxx,pinbetween, 'b','FaceAlpha',0.4,'LineStyle','none','FaceColor',blue_color);
        fill(nxx,ninbetween, 'k','FaceAlpha',0.4, 'LineStyle','none','FaceColor',gray_color);
        if (~strcmp(drug,'DMSO'))
            fill(xx1,inbetween1, 'r','FaceAlpha',0.4,'LineStyle','none','FaceColor','r');
        end

%        Marker Type. ' + '. Plus sign. ' o '. Circle. ' * '. Asterisk. ' . ' Point. ' x '. Cross. ' square ' or ' s '. Square. ' diamond ' or ' d ' 

        e3= plot(px,py,'s')
        e3.MarkerSize = 4;
        e3.MarkerFaceColor= 'none';
        e3.MarkerEdgeColor= blue_color;
        e3.Color = blue_color;

        e1= plot(nx,ny,'d'); 
        e1.MarkerSize = 4;
        e1.MarkerFaceColor= 'none';
        e1.MarkerEdgeColor= gray_color;
        e1.Color = gray_color;
        if (~strcmp(drug,'DMSO'))      
            e2=  plot(x1,y1,'^'); 
            e2.MarkerSize = 4;
            e2.MarkerFaceColor= orange_color;
            e2.MarkerEdgeColor= 'r';
            e2.Color = 'r';
        end
%%Set X Y limits
        ylim([-0.05,0.4]);
        xlim([-5,50]);
        set(gca,'FontSize',16);
        xlabel('Venus_{Free}  ({\mu}M)','FontSize',18, 'FontWeight', 'bold'); 
        ylabel('Bound Fraction','FontSize',18,'FontWeight', 'bold');
        title(celltype,'FontSize',18);
 
        %%Add legend
            pos_well_legend_title = strcat(char(positive_control), ' + ', ' DMSO');
            neg_well_legend_title = strcat(char(negative_control), ' + ', ' DMSO');
            well_legend_title = strcat(char(transfection),' + ', " ", char(concentration),"  ",char(drug)); 
            
            if (strcmp(drug,'DMSO'))
                 legend({pos_well_legend_title,neg_well_legend_title});
            else 
                legend({pos_well_legend_title,neg_well_legend_title, well_legend_title});
            end
            hold off;
            legend show;
            hold on; 
            hLegend = findobj(gcf, 'Type', 'Legend');
            hLegend.Location = 'northwest'; 
            legend('FontSize',12);
         
        set(gca,'PlotBoxAspectRatio',[1,1,1]);
        set(gcf, 'Renderer', 'Painters');
        saveas(gcf,plot_path,'epsc');
        saveas(gcf,plot_path,'jpg'); 
        close all; 
     
     
     
 end
 
end

close all
clear all



