kmt_path = '/Users/arturnowicki/IOPAN/data/grids/115/';
data_path = '/Users/arturnowicki/IOPAN/data/boundary_conditions/out_data/';

kmt_file = strcat(kmt_path, 'kmt.bs01v1.ocn.20180432.ieeer4');
surf_file = strcat(data_path, '2011-01-01-03600_SSH_1000_0640_0001_0001.ieeer8');
data_3d_file = strcat(data_path, '2011-01-01-03600_TEMP_1000_0640_0033_0001.ieeer8');

iIn = 1000; jIn = 640; kIn = 33;

fid = fopen(kmt_file, 'r', 'b');
    kmt_data = fread(fid, [iIn jIn], 'int');
fclose(fid);
fid = fopen(surf_file, 'r', 'b');
    surf_data = fread(fid, [iIn jIn], 'double');
fclose(fid);
fid = fopen(data_3d_file, 'r', 'b');
    temp_data = fread(fid, [iIn*jIn, kIn], 'double');
fclose(fid);
temp_lvl = 11;
kmt_mask = zeros(size(kmt_data));
kmt_mask(kmt_data>temp_lvl-1) = 1;
temp_lvl_data = reshape(temp_data(:, temp_lvl), iIn, jIn);
t10=temp_lvl_data;
% figure(1);
% pcolor(kmt_mask'); shading 'flat'; colorbar;
figure(2);
pcolor(surf_data'); shading 'flat'; colorbar;
figure(3);
pcolor(temp_lvl_data'); shading 'flat'; colorbar;
figure(5);
pcolor((temp_lvl_data.*kmt_mask)'); shading 'flat'; colorbar;
figure(4);
plot(surf_data(:, 250));

%%
caxis([4.1 4.8]);

%%
pcolor((t5-t10)'); colorbar; shading 'flat';