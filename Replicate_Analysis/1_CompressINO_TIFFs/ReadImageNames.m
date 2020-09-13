function [ FList ] = ReadImageNames(DataFolder,OutputFolder)
DirContents=dir(DataFolder);
FList = [];
NameSeperator='\'; %Path Seperating Char for Windows OS Dir\SubDir\FileName
extList={'tif','tiff'};
for i=1:numel(DirContents)
   %Check to make sure that the diectory does not start with '.' , '..'
    if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
        %if it is not a directory check if it is a tif file
        if(~DirContents(i).isdir)
            extension=DirContents(i).name(end-2:end);
            %if it is a tif file then compress it else just copy it as is
            if(numel(find(strcmpi(extension,extList)))~=0)
               
                input_file = [DataFolder,NameSeperator,DirContents(i).name] ;
                output_file = [OutputFolder,NameSeperator,DirContents(i).name]
                compression_status = CompressINOTiff(input_file, output_file); 
                if(compression_status == -1)%compression failed due to data corruption
                    %Append Failed File Name to A List
                    fileID = fopen([OutputFolder,NameSeperator,'FailedFileNames.txt'],'a');
                    fprintf(fileID,'%s\n',output_file);
                    fclose(fileID);
                elseif(compression_status == 1) %Compression not needed, data already compressed
                    copyfile([DataFolder,NameSeperator,DirContents(i).name], [OutputFolder,NameSeperator,DirContents(i).name]);
                end
            else
                %if file is not a tif copy file to output folder
                 copyfile([DataFolder,NameSeperator,DirContents(i).name], [OutputFolder,NameSeperator,DirContents(i).name]);
            end
        else
            %let's make sure that the destination folder contains the same
            %directory for copying
            if(~exist(fullfile([OutputFolder,NameSeperator,DirContents(i).name]),'dir'))
                mkdir([OutputFolder,NameSeperator], DirContents(i).name)
            end
            %If Directory is detected then we go through a recursive call
            %for the sub directory
            getlist=ReadImageNames([DataFolder,NameSeperator,DirContents(i).name], [OutputFolder,NameSeperator, DirContents(i).name]);
        end
    end
end
end