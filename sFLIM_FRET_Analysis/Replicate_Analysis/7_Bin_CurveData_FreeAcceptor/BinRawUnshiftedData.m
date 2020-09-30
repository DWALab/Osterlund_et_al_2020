function  BinRawUnshiftedData(filename)
% Fucntion used to extract binding information from each filtered_raw.csv file. 
% The first set of information are used for sFLIM-FRET analysis (Bound fraction vs free Acceptor using phasor analysis)
%          - exported to subfolder Phasor_Binned_Curves
% The second set of information exported is also bound fraction vs free acceptor (using INO Maximum Likelihood anlaysis)
%          - exported to subfolder INO_Binned_Curves
% The third binding infromation represent the classic FRET efficiency vs Acceptor to Donor Ratio
%          - exported to subfolder AD_FRET_Binned_Curves      


    %%%%%% USER DEFINED PARAMTERS%%%%%%
    % free acceptor bin edges defined by the user (in uM)
    bins =[-1,1,2,3,4,6,8,10,12,16,20,30,40,50];

    %acceptor to donor ratio bin edges 
    bins2 =[-1,1,2,3,4,6,8,10,12,16,20,30,40,50,60,80,100,150,200,250,300];

    %%%%% Analysis starts here
    data = csvread(filename,2); 
    %Get phasor binding curves free acceptor vs bound fraction
    mC3= data(:,2); %donor concentration
    FA = data(:,3); % free acceptor concentration
    B= data(:,4); % bound fraction

    mC3= mC3(~isnan(B));
    FA = FA(~isnan(B)); 
    B= B(~isnan(B));
    %Here user can designate desired thresholds on Free Venus (FA) and/or
    %mCerulean3 (mC3)
    B=B(FA<50 & mC3>1 & mC3<3); 
    FA=FA(FA<50 & mC3>1 & mC3<3); 

    [filepath,name,ext] = fileparts(filename);
    name = name(1:end-13);

    %%%% If alternate bins desired alter numbers within [#,#,#] below
    [b,byy,bey,points_per_bin,std_dev_x,std_dev_y]  = BinCurveData(FA,B,bins);

    col_names = {'Binned_Free_Acceptor','Binned_Bound_Fraction','Bf_std_error','Points_Per_Bin','FA_std','Bf_std'}; 

    output_csv_name = fullfile(pwd,'Phasor_Binned_Curves',strcat(name,'_binned',ext));
    csv_results= [b' byy' bey' points_per_bin' std_dev_x' std_dev_y'] ; 

    SaveToCSVWithColumnNames(output_csv_name,csv_results,col_names); 


    %%% GET INO BINDING CURVES
    %Get INO binding curves
    ino_FA = data(:,6);
    ino_B= data(:,7);
    ino_FA = ino_FA(~isnan(ino_B)); 
    ino_B= ino_B(~isnan(ino_B));
    mC3= mC3(~isnan(ino_B));
    ino_B=ino_B(ino_FA<50 & mC3>1 & mC3<4); 
    ino_FA=ino_FA(ino_FA<50 & mC3>1 & mC3<4); 

    [ino_b,ino_byy,ino_bey,points_per_bin,std_dev_x,std_dev_y]  = BinCurveData(ino_FA,ino_B,bins);
    output_csv_name = fullfile(pwd,'INO_Binned_Curves',strcat(name,'_binned',ext));
    ino_csv_results= [ino_b' ino_byy' ino_bey' points_per_bin' std_dev_x' std_dev_y'] ; 

    SaveToCSVWithColumnNames(output_csv_name,ino_csv_results,col_names); 

    %%% GET A:D ratio Curves
    AD_FA = data(:,8);
    AD_B= data(:,5);
    AD_B=AD_B(mC3>1); 
    AD_FA=AD_FA(mC3>1); 
    
    [AD_b,AD_byy,AD_bey,points_per_bin, std_dev_x,std_dev_y]  = BinCurveData(AD_FA,AD_B,bins2);
    output_csv_name = fullfile(pwd,'AD_FRET_Binned_Curves',strcat(name,'_binned',ext));
    AD_csv_results= [AD_b' AD_byy' AD_bey' points_per_bin' std_dev_x' std_dev_y'] ; 

    col_names2 = {'AcceptorDonor_Intensity_Ratio','Binned_FRET','FRET_std_error','Points_Per_Bin','FRET_std','FRET_std'};
    SaveToCSVWithColumnNames(output_csv_name,AD_csv_results,col_names2); 


end

