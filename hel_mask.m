close all;
clear all;
%%
kmt_file='/Users/arturnowicki/IOPAN/data/grids/2km/kmt_2km.ieeer8';
% kmt_file = '/Users/arturnowicki/IOPAN/data/grids/115/kmt.bs01v1.ocn.20180432.ieeer4';
% iIn = 1000; jIn = 640;
iIn = 600; jIn = 640;
fid = fopen(kmt_file, 'r', 'b');
    kmt = fread(fid, [iIn jIn], 'double');
fclose(fid);
tt = 0
mask=zeros(size(kmt));
mask_tmp = mask;
mask(kmt>tt) = 1;
mm = 1;
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
mask(323,40:79)=0;
mask(324,40:79)=0;
mask(325,40:79)=0;
mask(326,40:77)=0;
mask(327,40:75)=0;
mask(328,40:74)=0;
mask(329,40:73)=0;
% mask(330,40:71)=0;
% mask(331,40:71)=0;
mask(332,40:59)=0;
mask(333,40:59)=0;
mask(334,40:59)=0;
mask(333:345,30:59)=0;

% --------------------
% 115m cutout
% mask_tmp(55:83,1:502)=mm;
% mask_tmp(84:96,1:494)=mm;
% mask_tmp(97:102,1:490)=mm;
% mask_tmp(103:115,1:481)=mm;
% mask_tmp(116:131,1:472)=mm;
% mask_tmp(132:142,1:464)=mm;
% mask_tmp(143:154,1:457)=mm;
% mask_tmp(155:163,1:451)=mm;
% mask_tmp(164:175,1:444)=mm;
% mask_tmp(176:184,1:439)=mm;
% mask_tmp(185:190,1:431)=mm;
% mask_tmp(191:205,1:425)=mm;
% mask_tmp(206:218,1:416)=mm;
% mask_tmp(219:225,1:410)=mm;
% mask_tmp(226:235,1:403)=mm;
% mask_tmp(236:245,1:390)=mm;
% mask_tmp(245:265,1:374)=mm;
% mask_tmp(266:280,1:340)=mm;
% mask_tmp(281:290,1:340)=mm;
% mask_tmp(291:294,1:330)=mm;
% mask(mask_tmp~=1) = 0;
% kmt_mask=zeros(size(kmt));
% kmt_mask(kmt>0) = 1;
% tmp_data = kmt_mask + mask;
% mask(tmp_data==2) = 0;
% mask(tmp_data==1) = 1;
% mask(1:10, 550:640) = 1;
% mask(1:910, 635:640) = 1;

% --------------------
level = string(tt+1);
figure(1);
pcolor(mask(310:380,50:120)'); shading 'flat'; colorbar;
% hel_msk=strcat('/Users/arturnowicki/IOPAN/data/grids/115/masks/sea_mask_115m_',level,'_new.ieeer8');
hel_msk=strcat('/Users/arturnowicki/IOPAN/data/grids/2km/masks/sea_mask_2km_',level,'_new.ieeer8');
fid = fopen(hel_msk, 'w', 'b');
fwrite(fid, mask, 'double');
fclose(fid);

%%
% iIn = 1000; jIn = 640;
iIn = 600; jIn = 640;

for ii = 1:21
    level = string(ii);
    in_fname = strcat('/Users/arturnowicki/IOPAN/data/grids/2km/masks/sea_mask_2km_',level,'_new.ieeer8')
    fid = fopen(in_fname, 'r', 'b');
    data = fread(fid, [iIn jIn], 'double');
    fclose(fid);
    mask3d(:,:,ii) = data;
end
% for ii = 1:33
%     level = string(ii);
%     in_fname = strcat('/Users/arturnowicki/IOPAN/data/grids/115/masks/sea_mask_115m_1_new.ieeer8');
%     fid = fopen(in_fname, 'r', 'b');
%     data = fread(fid, [iIn jIn], 'double');
%     fclose(fid);
%     mask3d(:,:,ii) = data;
% end
% fid = fopen('/Users/arturnowicki/IOPAN/code/boundary_conditions/input_data/grids/115m/3d_sea_mask_115m.ieeer8', 'w', 'b');
%%
fid = fopen('/Users/arturnowicki/IOPAN/code/boundary_conditions/input_data/grids/2km/3d_sea_mask_2km_new.ieeer8', 'w', 'b');
fwrite(fid, mask3d, 'double');
fclose(fid);

%%
iIn = 600; jIn = 640;

fid = fopen('/Users/arturnowicki/IOPAN/code/boundary_conditions/input_data/grids/2km/3d_bay_mask_2km.ieeer8', 'r', 'b');
data_bay = fread(fid, 'double');
fclose(fid);
%%
data_sea = reshape(data_sea, iIn, jIn, 21);
data_bay = reshape(data_bay, iIn, jIn, 21);
mask3d = data_bay+data_sea;
pcolor(data_sea(320:380,50:100,5)'), shading 'flat', colorbar;



