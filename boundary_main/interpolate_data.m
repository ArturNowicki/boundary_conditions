% specify input data
function intepolate_data(inFolder, outFolder, gridSize)
    files = dir(strcat(inFolder,'*.ieeer8'));
    firstFile = files(1);
    splitString = strsplit(firstFile.name, '_');
    iIn = str2double(splitString{3});
    jIn = str2double(splitString{4});
    method2d = 'natural';
    method3d = 'natural';
    gridDataDirectory = strcat('../input_data/grids/', gridSize, '/');
    levelsInFile = strcat('../input_data/grids/2km/vertical_2km_600x640.txt');
    tLongInFile = strcat('../input_data/grids/2km/tLong_2km_600_640.ieeer8');
    tLatInFile = strcat('../input_data/grids/2km/tLat_2km_600_640.ieeer8');
    tLongOutFile = strcat(gridDataDirectory, 'tLong_', gridSize, '_1000x640.ieeer8');
    tLatOutFile = strcat(gridDataDirectory, 'tLat_', gridSize, '_1000x640.ieeer8');
    levelsOutFile = strcat(gridDataDirectory, 'vertical_', gridSize, '_1000x640.txt');

    % initialize variables
    iOut = 1000; jOut = 640; kOut = 33;
    iOutS = '1000'; jOutS = '0640'; kOutS = '0033';
    iAreaMin = 180; iAreaMax = 420;
    jAreaMin = 10; jAreaMax = 160;

    % read and process grids parameters
    % in grid

    fid = fopen(tLongInFile, 'r', 'b');
        tLongIn = fread(fid, [iIn jIn], 'double');
    fclose(fid);
    fid = fopen(tLatInFile, 'r', 'b');
        tLatIn = fread(fid, [iIn jIn], 'double');
    fclose(fid);
    fid = fopen(tLongOutFile, 'r', 'b');
        tLongOut = fread(fid, [iOut jOut], 'double');
    fclose(fid);
    fid = fopen(tLatOutFile, 'r', 'b');
        tLatOut = fread(fid, [iOut jOut], 'double');
    fclose(fid);
    cutLat = tLatIn(150:420, 1:180);
    cutLong = tLongIn(150:420, 1:180);
    zIn=importdata(levelsInFile)';
    kIn = size(zIn,2);
    zIn(2:kIn+1) = zIn;
    zIn(1) = 0.0;
    
    levelsThickness=importdata(levelsOutFile)/100;
    levelsNo = size(levelsThickness, 1);
    zOut = nan(1,levelsNo);
    zOut(1) = levelsThickness(1);
    for ii = 2:levelsNo
        zOut(ii) = zOut(ii - 1) + levelsThickness(ii);
    end
    tLatInMat = reshape(repmat(tLatIn, 1, kIn), iIn, jIn, kIn);
    tLongInMat = reshape(repmat(tLongIn, 1, kIn), iIn, jIn, kIn);
    tLatOutMat = reshape(repmat(tLatOut, 1, kOut), iOut, jOut, kOut);
    tLongOutMat = reshape(repmat(tLongOut, 1, kOut), iOut, jOut, kOut);

    cutLatMat = tLatInMat(150:420, 1:180, 1:14);
    cutLongMat = tLongInMat(150:420, 1:180, 1:14);

    clearvars tLongIn tLatIn tLongInMat tLatInMat levelsThickness 
    %% interpolate restart data
    c = parcluster('local');
    c.NumWorkers = 24;
    parpool(c, c.NumWorkers);
    tic
    for inFile=files'
        disp(inFile.name);
        splitString = strsplit(inFile.name, '_');
        dateTime = splitString{1};
        varName = splitString{2};
        kIn = str2double(splitString{5});
        suffix = splitString{7};
        fidIn = fopen(strcat(inFolder, inFile.name), 'r', 'b');
        inData = fread(fidIn, [iIn*jIn kIn], 'double');
        fclose(fidIn);
        if(kIn>1)
            inData = reshape(inData, iIn, jIn, kIn);
            inData(:, :, 2:kIn+1) = inData;
            tmpData = verticalInterpolation(iIn, jIn, kOut, zIn, zOut, inData);    
            cutData = tmpData(150:420, 1:180, :);
            outData = zeros(iOut, jOut, kOut);
            parfor kk = 1:kOut
                outData(:, :, kk) = griddata(cutLat, cutLong, cutData(:, :, kk), tLatOut, tLongOut, method3d);
            end
            outFile=strcat(outFolder,dateTime,'_',varName,'_',iOutS,'_',jOutS,'_',kOutS,'_0001_',suffix);
        else
            inData = reshape(inData, iIn, jIn);
            cutData = inData(150:420, 1:180);
            outData = zeros(iOut, jOut);
            outData(:, :) = griddata(cutLat, cutLong, cutData(:, :), tLatOut, tLongOut, method3d);
            outFile=strcat(outFolder,dateTime,'_',varName,'_',iOutS,'_',jOutS,'_0001_0001_',suffix);
        end
        if(min(min(inData)) >= 0.0)
            outData(outData < 0) = 0;
        end
        fidOut = fopen(outFile, 'w', 'b');
        fwrite(fidOut, outData, 'double');
        fclose(fidOut);
    end
%     toc
%    delete(gcp('nocreate'));
end
function outData = verticalInterpolation(iIn, jIn, kOut, zIn, zOut, inVar3d)
    tmpVar3d = nan(iIn, jIn, kOut);
    for ii = 1:iIn
        parfor jj = 1:jIn
            warning('off', 'MATLAB:interp1:NaNstrip');
            tmpVar3d(ii, jj, :) = interp1(zIn', squeeze(inVar3d(ii, jj, :)), zOut', 'spline');
        end
    end
    outData = tmpVar3d;
end
