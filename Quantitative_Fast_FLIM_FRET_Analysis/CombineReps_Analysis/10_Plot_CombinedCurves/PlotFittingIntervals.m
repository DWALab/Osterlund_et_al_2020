close all; clear all; clc; 
path = 'C:\Users\osterlund\Desktop\MatLab_Analysis\Bcl2_mim2_CombineReps\CombinedBinned_All_Reps';


positive_control = 'combined_filtered_raw_binned_C2.csv';
concentration1 = 'combined_filtered_raw_binned_A3.csv';
concentration2 = 'combined_filtered_raw_binned_A4.csv';
concentration3 = 'combined_filtered_raw_binned_A5.csv'; 
negative_control = 'combined_filtered_raw_binned_B16.csv';

fname1 = fullfile(path,positive_control); 
fname2 = fullfile(path,concentration1); 
fname3 = fullfile(path,concentration2);
fname4 = fullfile(path,concentration3);
fname5 = fullfile(path,negative_control); 

saturation = 0.15;
[px,py,pdy,pxx,pinbetween] = FitAndGetConfInterval(fname1,saturation); 
[nx,ny,ndy,nxx,ninbetween] = FitAndGetConfInterval(fname5,saturation); 

[x1,y1,dy1,xx1,inbetween1] = FitAndGetConfInterval(fname2,saturation); 

[x2,y2,dy2,xx2,inbetween2] = FitAndGetConfInterval(fname3, saturation); 
[x3,y3,dy3,xx3,inbetween3] = FitAndGetConfInterval(fname4, saturation);

gray_color =[0.5 0.5 0.5]; 

% figure;
figure('units','normalized','outerposition',[0 0 1 1])
subplot(1,3,1);
hold on; 
title('ABT-263 5{\mu}M'); 
fill(pxx,pinbetween, 'k','FaceAlpha',0.8, 'LineStyle','none')
fill(xx1,inbetween1, 'b','FaceAlpha',0.2,'LineStyle','none','FaceColor',gray_color)
fill(nxx,ninbetween, 'r','FaceAlpha',0.2,'LineStyle','none')
plot(px,py,'ko','MarkerFace','k'); 
plot(x1,y1,'b^','MarkerFace',gray_color,'MarkerEdgeColor',gray_color); 
plot(nx,ny,'rs','MarkerFace','r'); 
ylim([0,0.25]);
xlabel('Free Venus ({\mu}M)'); 
ylabel('Bound Fraction'); 
set(gca,'FontSize',16);
set(gca,'PlotBoxAspectRatio',[1,1,1]);
subplot(1,3,2);
hold on; 
title('ABT-263 10{\mu}M'); 
fill(pxx,pinbetween, 'k','FaceAlpha',0.8, 'LineStyle','none')
fill(xx2,inbetween2, 'b','FaceAlpha',0.2,'LineStyle','none','FaceColor',gray_color)
fill(nxx,ninbetween, 'r','FaceAlpha',0.2,'LineStyle','none')
plot(px,py,'ko','MarkerFace','k'); 
plot(x2,y2,'b^','MarkerFace',gray_color,'MarkerEdgeColor',gray_color); 
plot(nx,ny,'rs','MarkerFace','r'); 
ylim([0,0.25]);
xlabel('Free Venus ({\mu}M)'); 
ylabel('Bound Fraction'); 

set(gca,'PlotBoxAspectRatio',[1,1,1]);
set(gca,'FontSize',16); 
subplot(1,3,3);


hold on; 
title('ABT-263 20{\mu}M'); 
fill(pxx,pinbetween, 'k','FaceAlpha',0.8, 'LineStyle','none')
fill(xx3,inbetween1, 'b','FaceAlpha',0.2,'LineStyle','none','FaceColor',gray_color)
fill(nxx,ninbetween, 'r','FaceAlpha',0.2,'LineStyle','none')
plot(px,py,'ko','MarkerFace','k'); 
plot(x3,y3,'b^','MarkerFace',gray_color,'MarkerEdgeColor',gray_color); 
plot(nx,ny,'rs','MarkerFace','r'); 
xlabel('Free Venus ({\mu}M)'); 
ylabel('Bound Fraction'); 
set(gca,'FontSize',16);
ylim([0,0.25]);
set(gca,'PlotBoxAspectRatio',[1,1,1]);