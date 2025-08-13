% transform the Charles data to an array
%-----------------------------------------%
% fid_file:file path of Charles data
% w:width of data
% h:height of data
% reture: 2*w*h*kspace_num array
%-----------------------------------------%
function all_data=SMri2D_reader(fid_file,h,w)
    fid = fopen(fid_file, 'r');
    data_in = fread(fid,'float')';
    kspace_num = length(data_in)/2/h/w;
    
    all_data = reshape(data_in, [2,h,w,kspace_num]);
    fclose(fid);
end