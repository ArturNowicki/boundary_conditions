close all;
clear all;
kmt_file='/Users/arturnowicki/IOPAN/data/grids/2km/kmt_2km.ieeer8';
hel_msk='/Users/arturnowicki/IOPAN/data/grids/2km/hel_msk_2km.ieeer8';
iIn = 600; jIn = 640;
fid = fopen(kmt_file, 'r', 'b');
    kmt = fread(fid, [iIn jIn], 'double');
fclose(fid);

%%
hold off;
mask=nan(size(kmt));
mask(kmt>0) = 0;
% mask(307:370, 50:83)=2;
% mask(322:370, 82:83)=1;
% mask(307:370, 50:83)=2;
mask(318:321,74:83)=2;
mask(322,74:82)=2;
mask(323:324,80:81)=2;
mask(323,74)=2;
mask(325,79:80)=2;
mask(326,78:79)=2;
mask(327,76:78)=2;
mask(328,75:76)=2;
mask(329,74:75)=2;
mask(330,72:74)=2;
mask(323,75:79)=1;
mask(324,71:79)=1;
mask(325,64:78)=1;
mask(326,63:77)=1;
mask(327,63:75)=1;
mask(328,62:74)=1;
mask(329,62:73)=1;
mask(330,61:71)=1;
mask(331,61:71)=1;
mask(332,60:71)=1;

mask(333:335,1:59) = nan;
pcolor(mask'); shading 'faceted'; colorbar;
fid = fopen(hel_msk, 'w', 'b');
fwrite(fid, mask, 'double');
fclose(fid);


