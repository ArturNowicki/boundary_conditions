close all;
clear all;
kmt_file='/Users/arturnowicki/IOPAN/data/grids/2km/kmt_2km.ieeer8';
iIn = 600; jIn = 640;
fid = fopen(kmt_file, 'r', 'b');
    kmt = fread(fid, [iIn jIn], 'double');
fclose(fid);
%%
tt = 21
mask=zeros(size(kmt));
mask(kmt>tt) = 1;

mask(323,40:79)=0;
mask(324,40:79)=0;
mask(325,40:79)=0;
mask(326,40:77)=0;
mask(327,40:75)=0;
mask(328,40:74)=0;
mask(329,40:73)=0;
mask(330,40:71)=0;
mask(331,40:71)=0;
mask(332,40:59)=0;
mask(333:345,30:59)=0;


level = string(tt+1);
% pcolor(kmt_lev(300:350, 1:100)'); shading 'faceted'; colorbar;
pcolor(mask'); shading 'flat'; colorbar;
% pcolor(kmt_lev'); shading 'flat'; colorbar;
%%
hel_msk=strcat('/Users/arturnowicki/IOPAN/data/grids/2km/masks/sea_mask_2km_',level,'.ieeer8')
fid = fopen(hel_msk, 'w', 'b');
fwrite(fid, mask, 'double');
fclose(fid);

%%
iIn = 600; jIn = 640;

mask3d = zeros(600,640,21);
for ii = 1:9
    level = strcat('0',string(ii));
    in_fname = strcat('/Users/arturnowicki/IOPAN/data/grids/2km/masks/sea_mask_2km_',level,'.ieeer8');
    fid = fopen(in_fname, 'r', 'b');
    data = fread(fid, [iIn jIn], 'double');
    fclose(fid);
    mask3d(:,:,ii) = data;
end
for ii = 10:21
    level = string(ii);
    in_fname = strcat('/Users/arturnowicki/IOPAN/data/grids/2km/masks/sea_mask_2km_',level,'.ieeer8');
    fid = fopen(in_fname, 'r', 'b');
    data = fread(fid, [iIn jIn], 'double');
    fclose(fid);
    mask3d(:,:,ii) = data;
end
fid = fopen('/Users/arturnowicki/IOPAN/data/grids/2km/masks/3d_sea_mask_2km.ieeer8', 'w', 'b');
fwrite(fid, mask3d, 'double');
fclose(fid);

%%
pcolor(mask3d(:,:,6)'), shading 'flat', colorbar;
