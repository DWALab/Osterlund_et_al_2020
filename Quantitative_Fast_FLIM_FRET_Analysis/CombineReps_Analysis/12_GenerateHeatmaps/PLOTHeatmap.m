%Created by Nehad Hirmiz

% Instruction * copy and resulting generated parameter 'heatmap' data from Excel to the area
% below between [  ].  MAKE SURE NO WELLS are empty in the excel platemap
% if you have no data in a space make it 0 and make a note to delete it 
%HERE is some test data- delete and replace with whatever you want to plot
kd_map = [
1,2,3,4,5
6,7,8,9,10
11,12,13,14,15
]

imagesc(kd_map)
% optional color maps  "parula"= blue-green-yellow 
% "spring" = pink to yellow,  "hot"= red to yellow, 
% "cool"= cyan to pink, "summer" = green-yellow, "jet"= rainbow, gray= greyscale

myColorMap = jet(100);
myColorMap(1,:) = 0;
colormap(myColorMap);
colorbar()
caxis([0,20]);
axis image off;
  
