function status = CompressINOTiff(input_file,output_file)
%%% Compress INO Tiff Files 
% Status = 0 compression complete 
% Status = 1 Data is already compressed, no compresssion needed
% Status = -1 compression failed, file corrupted
FILENAME = input_file; 
%ino_img = Read_INO_FHS_File('TestINOScan.tif');
try
    infoStruct = imfinfo(FILENAME);
catch
    status = -1;
    return
end


%Check to see if file is compressed
if(strcmp(char(infoStruct(1).Compression),  'Uncompressed'))
    infoStruct(1).Compression ; 

    %Get number of pages
    numberOfPages = length(infoStruct);
    %TCSPC cube
    lifetime_cube = imread(FILENAME, 1); 
    %Spectral cube
    spectral_cube = imread(FILENAME, 2); 

    %Write TCSPC compressed to page 1
    t = Tiff(output_file,'w');
    setTag(t,'Photometric',Tiff.Photometric.MinIsBlack);
    setTag(t,'Compression',Tiff.Compression.LZW);
    setTag(t,'BitsPerSample',16);
    setTag(t,'SamplesPerPixel', ( infoStruct(1).SamplesPerPixel));
    setTag(t,'SampleFormat',Tiff.SampleFormat.UInt);
    setTag(t,'ImageLength',infoStruct(1).Height);
    setTag(t,'ImageWidth',infoStruct(1).Width);
    setTag(t,'PlanarConfiguration',1);
    setTag(t,'SubFileType', 0) ; 
    setTag(t,'FillOrder', 1); 
    setTag(t,'Orientation', 1) ; %Orientation 0th row represents the visual top left of the image
    setTag(t, 'RowsPerStrip', infoStruct(1).RowsPerStrip); %RowPerStrip
    setTag(t,'XResolution', (infoStruct(1).XResolution)) ;
    setTag(t,'YResolution', (infoStruct(1).YResolution)) %PlanerConfiguration = chunky
    setTag(t,'ResolutionUnit', 3); %ResolutionUnit = centimeter
    setTag(t,'ImageDescription', char(infoStruct(1).ImageDescription)); %MetaData stored in XML Format
    setTag(t,'MinSampleValue', 0); %MinSample Value = 0 
    setTag(t,'MaxSampleValue', 65535);%MaxSampleValue = 16^2 - 1 for 16-bit image
    setTag(t,'Thresholding', 1); %Threshold 1 = Bilevel
    setTag(t,'XPosition', (infoStruct(1).XPosition)); 
    setTag(t,'YPosition', (infoStruct(1).YPosition)); 
    setTag(t,'DateTime', char(infoStruct(1).DateTime)); 
    setTag(t, 'ExtraSamples', 0) %Extra data has unspecified format
    setTag(t,'SampleFormat', 1)%Sample Format Unsigned Int
    write(t, lifetime_cube); 
    close(t); 

    %Append the Spectral cube to page 2 with compression
    t = Tiff(output_file,'a');
    setTag(t,'Photometric',Tiff.Photometric.MinIsBlack);
    setTag(t,'Compression',Tiff.Compression.LZW);
    setTag(t,'BitsPerSample',16);
    setTag(t,'SamplesPerPixel', ( infoStruct(2).SamplesPerPixel));
    setTag(t,'SampleFormat',Tiff.SampleFormat.UInt);
    setTag(t,'ImageLength',infoStruct(2).Height);
    setTag(t,'ImageWidth',infoStruct(2).Width);
    setTag(t,'PlanarConfiguration',1);
    setTag(t,'SubFileType', 0) ; 
    setTag(t,'FillOrder', 1); 
    setTag(t,'Orientation', 1) ; %Orientation 0th row represents the visual top left of the image
    setTag(t, 'RowsPerStrip', infoStruct(2).RowsPerStrip); %RowPerStrip
    setTag(t,'XResolution', (infoStruct(2).XResolution)) ;
    setTag(t,'YResolution', (infoStruct(2).YResolution)) %PlanerConfiguration = chunky
    setTag(t,'ResolutionUnit', 3); %ResolutionUnit = centimeter
    setTag(t,'ImageDescription', char(infoStruct(2).ImageDescription)); %MetaData stored in XML Format
    setTag(t,'MinSampleValue', 0); %MinSample Value = 0 
    setTag(t,'MaxSampleValue', 65535);%MaxSampleValue = 16^2 - 1 for 16-bit image
    setTag(t,'Thresholding', 1); %Threshold 1 = Bilevel
    setTag(t,'XPosition', (infoStruct(2).XPosition)); 
    setTag(t,'YPosition', (infoStruct(2).YPosition)); 
    setTag(t,'DateTime', char(infoStruct(2).DateTime)); 
    setTag(t, 'ExtraSamples', 0) %Extra data has unspecified format
    setTag(t,'SampleFormat', 1)%Sample Format Unsigned Int
    write(t, spectral_cube); 
    close(t); 

    status = 0 ;
else
    status = 1;
end
end