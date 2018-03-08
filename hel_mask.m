close all;
clear all;
kmt_file = '/Users/arturnowicki/IOPAN/data/grids/115/kmt_115m_1000x640.ieeei4';
iIn = 1000; jIn = 640;
fid = fopen(kmt_file, 'r', 'b');
    kmt = fread(fid, [iIn jIn], 'int');
fclose(fid);
%%
tt = 0
mask=zeros(size(kmt));
mask(kmt>tt) = 1;
mm = 0;
mask(55:83,1:502)=mm;
mask(84:96,1:494)=mm;
mask(97:102,1:490)=mm;
mask(103:115,1:481)=mm;
mask(116:131,1:472)=mm;
mask(132:142,1:464)=mm;
mask(143:154,1:457)=mm;
mask(155:163,1:451)=mm;
mask(164:175,1:444)=mm;
mask(176:184,1:439)=mm;
mask(185:190,1:431)=mm;
mask(191:205,1:425)=mm;
mask(206:218,1:416)=mm;
mask(219:225,1:410)=mm;
mask(226:235,1:403)=mm;
mask(236:245,1:390)=mm;
mask(245:265,1:374)=mm;
mask(266:290,1:340)=mm;
mask(291:294,1:330)=mm;



level = string(tt+1);
% pcolor(kmt_lev(300:350, 1:100)'); shading 'faceted'; colorbar;
pcolor(mask'); shading 'flat'; colorbar;
% pcolor(kmt_lev'); shading 'flat'; colorbar;
%%
hel_msk=strcat('/Users/arturnowicki/IOPAN/data/grids/2km/masks/sea_mask_115m_',level,'.ieeer8')
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
