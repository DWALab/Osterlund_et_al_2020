function [imageStruct,summaryTable] = Read_INO_FHS_File(FILENAME)

%Read_INO_FHS_File Reads INO_F-HS TIFF files.
%   [imageStruct,summaryTable] = Read_INO_FHS_File(filename) reads a TIFF
%   file FILENAME.  The file should have been produced by one of the
%   INO_F-HS software suite components.  It supports both the raw
%   acquisition files and the analysis files.
%
%   imageStruct is a struct array containing the images stored in the file.
%   Each structure contains 5 fields: Image, ImageType, SequenceUID,
%   FrameID and Metadata:
%
%   Image:       m-by-n-by-p containing the imaged data of a specific type.
%   ImageType:   A string describing the type of data of this element.
%   SequenceUID: A string containing the unique sequence ID assigned during
%                acquisition.  All images with the same sequence UID are
%                related to the same sequence of scans.
%   FrameID:     A string representing the sequential number of the frame
%                within the sequence. In the case of a cumulative frame
%                analysis result, the frame ID will contain the information
%                regarding which frame were accumulated.
%   Metadata:    a structure containing the meta-information involved in
%                creating the image.
%
%  summaryTable is a table summarizing the contents of the file.
%
% See also:
%
% Dependencies: This function needs the function xml2struct, available on
% MathWorks File Exchange: https://www.mathworks.com/matlabcentral/fileexchange/28518-xml2struct

% Legal Notice: Copyright (c) 2017 INO, All Rights Reserved.
% Address: INO, Sainte-Foy, Quebec, Canada.  (418) 657-7006
%
% Author: Sébastien Roy


tempFile = fullfile('c:\temp',['ReadINO_FHS_File-',datestr(now,30),'.xml']);

infoStruct = imfinfo(FILENAME);
numberOfPages = length(infoStruct);

tmpImgStruct(numberOfPages).Image = [];
tmpImgStruct(numberOfPages).ImageType = '';
tmpImgStruct(numberOfPages).SequenceUID = '';
tmpImgStruct(numberOfPages).FrameID = '';
tmpImgStruct(numberOfPages).Metadata = struct;


imageTypes   = cell(numberOfPages,1);
sequenceUIDs = cell(size(imageTypes));
frameIDs     = cell(size(imageTypes));
allSFID      = cell(size(imageTypes));

for iPage = 1:numberOfPages,
    tmpImgStruct(iPage).Image = imread(FILENAME,iPage);
    rawXML = infoStruct(iPage).ImageDescription;
    if ~strcmpi(rawXML,'Dummy IFD0')
        % Needs to pass to a file since xml2struct handles only files.
        fid = fopen(tempFile,'w','n','UTF-8'); % Trick to encode correctly to UTF-8
        fprintf(fid,'%s\n',rawXML);
        fclose(fid);
        encodedStruct = xml2struct(tempFile);
        encodedBase   = encodedStruct.INOmetaData.All;
        decodedBase   = decodeTree(encodedBase);
        imageType = decodedBase.ImageType;
        sequenceUID = decodedBase.SequenceUID;
        frameID = decodedBase.FrameID;
        tmpImgStruct(iPage).Metadata = decodedBase;
    else
        imageType = 'Dummy';
        sequenceUID = 'Dummy';
        frameID = 'Dummy';
        tmpImgStruct(iPage).Metadata = struct;
    end
    tmpImgStruct(iPage).ImageType   = imageType;
    tmpImgStruct(iPage).SequenceUID = sequenceUID;
    tmpImgStruct(iPage).FrameID     = frameID;
    
    imageTypes{iPage}   = imageType;
    sequenceUIDs{iPage} = sequenceUID;
    frameIDs{iPage}     = frameID;
    allSFID{iPage}      = [sequenceUID,'_',frameID];
end

delete(tempFile);

% Merge Hyperspectral slices as a single cube.


hyperSpectralSlices = strcmp('HyperspectralCalibratedSlice',imageTypes);
nonSliceImages = true(size(tmpImgStruct));

if any(hyperSpectralSlices)
    uniqueSFID = unique(allSFID(hyperSpectralSlices));
    for iID = 1:length(uniqueSFID)
        slicesToMerge = find(strcmp(uniqueSFID{iID},allSFID) & hyperSpectralSlices);
        numberOfSlices = length(slicesToMerge);
        sliceIndexes  = zeros(size(slicesToMerge));
        for iSlice=1:numberOfSlices
            sliceIndexes(iSlice) = floor(tmpImgStruct(slicesToMerge(iSlice)).Metadata.SliceIndex);
        end
        uniqueSliceIndexes = unique(sliceIndexes);
        assert(length(uniqueSliceIndexes) == numberOfSlices);
        assert(uniqueSliceIndexes(1) == 0);
        assert(uniqueSliceIndexes(end) == numberOfSlices-1);
        [nr,nc] = size(tmpImgStruct(slicesToMerge(1)).Image);
        hsCube = zeros(nr,nc,numberOfSlices,'single');
        for iSlice=1:numberOfSlices
            hsCube(:,:,sliceIndexes(iSlice)+1) = tmpImgStruct(slicesToMerge(iSlice)).Image;
        end
        tmpImgStruct(end+1).Image     = hsCube;
        tmpImgStruct(end).ImageType   = 'HyperspectralCalibrated';
        tmpImgStruct(end).SequenceUID = sequenceUIDs{slicesToMerge(1)};
        tmpImgStruct(end).FrameID     = frameIDs{slicesToMerge(1)};
        tmpImgStruct(end).Metadata    = tmpImgStruct(slicesToMerge(1)).Metadata;
        tmpImgStruct(end).Metadata    = rmfield(tmpImgStruct(end).Metadata,'SliceIndex');
        tmpImgStruct(end).Metadata.ImageType = 'HyperspectralCalibrated';
    end
    nonSliceImages = ~strcmp('HyperspectralCalibratedSlice',{tmpImgStruct.ImageType});    
end

imageStruct = tmpImgStruct(nonSliceImages);

ImageType   = {imageStruct.ImageType}';
SequenceUID = {imageStruct.SequenceUID}';
FrameID     = {imageStruct.FrameID}';
Index = (1:length(ImageType))';
summaryTable = table(Index,SequenceUID,FrameID,ImageType);

end

function decodedStruct = decodeTree(encodedStruct)


if isfield(encodedStruct,'Attributes')
    propAttr = encodedStruct.Attributes;
    if isfield(propAttr,'PropertyType')
        propertyStr = propAttr.PropertyType;
        switch propertyStr
            case '0' %ePropertyNotSet
            case {'1', '2', '3'} %Signed, unsigned or float
                decodedStruct = str2double(encodedStruct.Text);
                return
            case '4' % string
                decodedStruct = encodedStruct.Text;
                return
            case '5' % tree; not expected to be seen
                tmpStruct = encodedStruct;
                tmpStruct = rmfield(tmpStruct,'Attributes');
                decodedStruct = decodeTree(tmpStruct);
                return
            case '6' % Vector
                decodedStruct = decodeVector(encodedStruct);
                return
            otherwise % Not suported type
                error('Unsupported property type');              
        end
    end
end

decodedStruct = struct;
allFields = fieldnames(encodedStruct);
allFields = setdiff(allFields,{'Attributes','Text'});

if isempty(allFields)
    if isfield(encodedStruct,'Text')
        decodedStruct = encodedStruct.Text;
    else
        decodedStruct = [];
    end
    return
end

for iField = 1:length(allFields)
    decodedStruct.(allFields{iField}) = decodeTree(encodedStruct.(allFields{iField}));
end


end

function vec = decodeVector(encodedVector)

vectorSize = str2double(encodedVector.VectorSize.Text);
assert(vectorSize >= 0);

theFields = fieldnames(encodedVector);
numOfFields = length(theFields);
assert(length(theFields) >= vectorSize+2);
elementsMatrix = zeros(numOfFields,2);
currentIndex = 0;
for iField = 1:numOfFields
    curField = theFields{iField};
    elemLocations = strfind(curField,'Elem');
    if length(elemLocations) ~= 1
        continue
    end
    if elemLocations ~= 1
        continue
    end
    currentIndex = currentIndex + 1;
    elementsMatrix(currentIndex,1) = floor(str2double(curField(5:end)));
    elementsMatrix(currentIndex,2) = str2double(encodedVector.(curField).Text);
end

assert(currentIndex == vectorSize);
elementsMatrix = elementsMatrix(1:currentIndex,:);

if isempty(elementsMatrix)
    vec = [];
    return
end

indexes = unique(elementsMatrix(:,1));
assert(length(indexes) == length(elementsMatrix));
assert(indexes(1) == 0);
assert(indexes(end) == vectorSize-1);

sortedMatrix = sortrows(elementsMatrix,1);

vec = sortedMatrix(:,2)';

end
