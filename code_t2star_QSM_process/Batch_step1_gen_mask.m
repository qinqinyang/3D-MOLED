clc;
clear;

file_path = 'Data/';
tar='Data_mask_echo4/';
echo = 4;

dirlist = dir([file_path,'sub*']);
dirn=length(dirlist);

if ~exist(tar,'dir')==1
    mkdir(tar);
end

%%
parfor loopdir=1:dirn
    tarsub = [tar,dirlist(loopdir).name,'/'];
    if ~exist(tarsub,'dir')==1
        mkdir(tarsub);
    end
    dir_fn1 = [file_path,dirlist(loopdir).name,'/scan_01/'];
    dir_fn2 = [file_path,dirlist(loopdir).name,'/scan_02/'];
    
    filelist1 = dir([dir_fn1,'*M.nii']);
    filelist2 = dir([dir_fn2,'*M.nii']);
    
    file_in1 = [dir_fn1,filelist1(echo).name];
    file_out1 = [tarsub,'/scan_01_mask.nii'];

    file_in2 = [dir_fn2,filelist2(echo).name];
    file_out2 = [tarsub,'/scan_02_mask.nii'];

    % fls bet2
    cmd = ['/home/yqq/fsl/share/fsl/bin/bet ',file_in1,' ',file_out1,' -m -n'];
    status = system(cmd);

    cmd = ['/home/yqq/fsl/share/fsl/bin/bet ',file_in2,' ',file_out2,' -m -n'];
    status = system(cmd);

    disp(loopdir);
end
