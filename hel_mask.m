close all;
clear all;
kmt_file='/Users/arturnowicki/IOPAN/data/grids/2km/kmt_2km.ieeer8';
hel_msk='/Users/arturnowicki/IOPAN/data/grids/2km/masks/sea_mask_2km_01.ieeer8';
iIn = 600; jIn = 640;
fid = fopen(kmt_file, 'r', 'b');
    kmt = fread(fid, [iIn jIn], 'double');
fclose(fid);
%%
mask=zeros(size(kmt));

% mask(323,75:79)=1;
% mask(324,71:79)=1;
% mask(325,70:74)=1;
% mask(326,68:75)=1;
% mask(327,66:75)=1;
% mask(328,65:74)=1;
% mask(329,65:73)=1;
% mask(330,65:71)=1;
% mask(331,63:71)=1;
% mask(332,63:71)=1;

mask(300:303,1:79)=1;


kmt_lev = kmt<1;
% pcolor(kmt_lev(300:350, 1:100)'); shading 'faceted'; colorbar;
pcolor(kmt_lev(300:350, 1:100)'+mask(300:350, 1:100)'); shading 'faceted'; colorbar;
% pcolor(kmt_lev'); shading 'flat'; colorbar;
%%
fid = fopen(hel_msk, 'w', 'b');
fwrite(fid, mask, 'double');
fclose(fid);

%%
iIn = 600; jIn = 640;

mask3d = zeros(600,640,21);
for ii = 1:9
    level = strcat('0',string(ii));
    in_fname = strcat('/Users/arturnowicki/IOPAN/data/grids/2km/masks/bay_mask_2km_',level,'.ieeer8');
    fid = fopen(in_fname, 'r', 'b');
    data = fread(fid, [iIn jIn], 'double');
    fclose(fid);
    mask3d(:,:,ii) = data;
end
for ii = 10:21
    mask3d(:,:,ii) = data;
end
fid = fopen('/Users/arturnowicki/IOPAN/data/grids/2km/masks/3d_bay_mask_2km.ieeer8', 'w', 'b');
fwrite(fid, mask3d, 'double');
fclose(fid);

%%
pcolor(mask3d(:,:,16)'), shading 'flat', colorbar;
