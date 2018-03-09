close all;
clear all;
%%
kmt_file = '/Users/arturnowicki/IOPAN/data/grids/115/kmt_115m_1000x640.ieeei4';
iIn = 1000; jIn = 640;
fid = fopen(kmt_file, 'r', 'b');
    kmt = fread(fid, [iIn jIn], 'int');
fclose(fid);
tt = 23;
mask=zeros(size(kmt));
mask_tmp = mask;
mask(kmt>tt) = 1;
mm = 1;
mask_tmp(55:83,1:502)=mm;
mask_tmp(84:96,1:494)=mm;
mask_tmp(97:102,1:490)=mm;
mask_tmp(103:115,1:481)=mm;
mask_tmp(116:131,1:472)=mm;
mask_tmp(132:142,1:464)=mm;
mask_tmp(143:154,1:457)=mm;
mask_tmp(155:163,1:451)=mm;
mask_tmp(164:175,1:444)=mm;
mask_tmp(176:184,1:439)=mm;
mask_tmp(185:190,1:431)=mm;
mask_tmp(191:205,1:425)=mm;
mask_tmp(206:218,1:416)=mm;
mask_tmp(219:225,1:410)=mm;
mask_tmp(226:235,1:403)=mm;
mask_tmp(236:245,1:390)=mm;
mask_tmp(245:265,1:374)=mm;
mask_tmp(266:290,1:340)=mm;
mask_tmp(291:294,1:330)=mm;
mask(mask_tmp~=1) = 0;



level = string(tt+1);
% pcolor(mask(1:320, 300:550)'); shading 'flat'; colorbar;
pcolor(mask'); shading 'flat'; colorbar;

hel_msk=strcat('/Users/arturnowicki/IOPAN/data/grids/115/masks/bay_mask_115m_',level,'.ieeer8');
fid = fopen(hel_msk, 'w', 'b');
fwrite(fid, mask, 'double');
fclose(fid);

%%
iIn = 1000; jIn = 640;

mask3d = zeros(iIn,jIn,33);
% for ii = 1:9
%     level = strcat('0',string(ii));
%     in_fname = strcat('/Users/arturnowicki/IOPAN/data/grids/115/masks/sea_mask_115m_',level,'.ieeer8');
%     fid = fopen(in_fname, 'r', 'b');
%     data = fread(fid, [iIn jIn], 'double');
%     fclose(fid);
%     mask3d(:,:,ii) = data;
% end
for ii = 1:23
    level = string(ii);
    in_fname = strcat('/Users/arturnowicki/IOPAN/data/grids/115/masks/bay_mask_115m_',level,'.ieeer8');
    fid = fopen(in_fname, 'r', 'b');
    data = fread(fid, [iIn jIn], 'double');
    fclose(fid);
    mask3d(:,:,ii) = data;
end
for ii = 24:33
    level = string(ii);
    in_fname = strcat('/Users/arturnowicki/IOPAN/data/grids/115/masks/bay_mask_115m_24.ieeer8');
    fid = fopen(in_fname, 'r', 'b');
    data = fread(fid, [iIn jIn], 'double');
    fclose(fid);
    mask3d(:,:,ii) = data;
end
fid = fopen('/Users/arturnowicki/IOPAN/code/boundary_conditions/input_data/grids/115m/tLat_115m_1000x640.ieeer8', 'w', 'b');
fwrite(fid, mask3d, 'double');
fclose(fid);

%%
iIn = 1000; jIn = 640;

fid = fopen('/Users/arturnowicki/IOPAN/code/boundary_conditions/input_data/grids/115m/tLat_115m_1000x640.ieeer8', 'w', 'b');
data = fread(fid, 'double');
fclose(fid);
% mask3d = reshape(mask3d, iIn, jIn, 33);
% pcolor(mask3d(:,:,33)'), shading 'flat', colorbar;



