% specify input data
inFolder = '../../../data/boundary_conditions/spread_data/';
outFolder = '../../../data/boundary_conditions/out_data/';
files = dir(strcat(inFolder,'*.ieeer8'));
firstFile = files(1);
splitString = strsplit(firstFile.name, '_');
iIn = str2double(splitString{3});
jIn = str2double(splitString{4});
kIn = str2double(splitString{5});
gridSize = '115';
method2d = 'natural';
method3d = 'natural';
gridDataDirectory = strcat('../../../data/grids/', gridSize, '/');
inDirectory = '../../../data/restarts/';
sampleModelFile = '../../../data/sample2kmHydroData.nc'; % to read tLong, tLat
levelsInFile = strcat('../../../data/grids/2km/vertical_2km_600x640.txt');

tLongOutFile = strcat(gridDataDirectory, 'tLong_', gridSize, 'm_1000x640.ieeer8');
tLatOutFile = strcat(gridDataDirectory, 'tLat_', gridSize, 'm_1000x640.ieeer8');
levelsOutFile = strcat(gridDataDirectory, 'vertical_', gridSize, 'm_1000x640.txt');

% initialize variables
iOut = 1000; jOut = 640; kOut = 33;
iOutS = '1000'; jOutS = '0640'; kOutS = '0033';
iAreaMin = 180; iAreaMax = 420;
jAreaMin = 10; jAreaMax = 160;

% read and process grids parameters
% in grid
ncidGrid = netcdf.open(sampleModelFile, 'NOWRITE');
    varId = netcdf.inqVarID(ncidGrid, 'TLONG');
    tLongIn = netcdf.getVar(ncidGrid, varId)/180*pi;
    varId = netcdf.inqVarID(ncidGrid, 'TLAT');
    tLatIn = netcdf.getVar(ncidGrid, varId)/180*pi;
netcdf.close(ncidGrid);
cutLat = tLatIn(150:420, 1:180);
cutLong = tLongIn(150:420, 1:180);
zIn=importdata(levelsInFile)';
zIn(2:kIn+1) = zIn;
zIn(1) = 0.0;

fid = fopen(tLongOutFile, 'r', 'b');
    tLongOut = fread(fid, [iOut jOut], 'double');
fclose(fid);

fid = fopen(tLatOutFile, 'r', 'b');
    tLatOut = fread(fid, [iOut jOut], 'double');
fclose(fid);

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
pool = gcp('nocreate');
if isempty(pool)
    parpool(4);
end

for inFile=files'
    disp(inFile.name);
    splitString = strsplit(inFile.name, '_');
    dateTime = splitString(1);
    varName = splitString(2);
    
    kIn = str2double(splitString{5});
    fidIn = fopen(strcat(inFolder, inFile.name), 'r', 'b');
    inData = fread(fidIn, [iIn*jIn kIn], 'double');
    fclose(fidIn);
    if(kIn>1)
        tic
        inData = reshape(inData, iIn, jIn, kIn);
        inData(:, :, 2:kIn+1) = inData;
        tmpData = verticalInterpolation(iIn, jIn, kOut, zIn, zOut, inData);    
        cutData = tmpData(150:420, 1:180, :);
        outData = zeros(iOut, jOut, kOut);
        parfor kk = 1:kOut
            outData(:, :, kk) = griddata(cutLat, cutLong, cutData(:, :, kk), tLatOut, tLongOut, method3d);
        end
        outFile=strcat(outFilder,dateTime,'_',varName,'_',iOutS,'_',jOutS,'_',kOutS,'_0001.ieeer8');
        tm2 = toc
    else
        tic
        inData = reshape(inData, iIn, jIn);
        cutData = inData(150:420, 1:180);
        outData = zeros(iOut, jOut);
        outData(:, :) = griddata(cutLat, cutLong, cutData(:, :), tLatOut, tLongOut, method3d);
        outFile=strcat(outFilder,dateTime,'_',varName,'_',iOutS,'_',jOutS,'_0001_0001.ieeer8');
        tm3 =toc
    end
    if(min(min(inData)) >= 0.0)
        outData(outData < 0) = 0;
    end
    fidOut = fopen(outFile, 'w', 'b');
    fwrite(fidOut, outData, 'double');
    fclose(fidOut);
    break;
end
    
delete(gcp('nocreate'));

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
