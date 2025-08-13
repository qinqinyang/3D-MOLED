clc;
clear;
addpath(genpath('tools'));

file_path = 'Data/';
tar='Data_3D_GRE_t2star/';

dirlist = dir([file_path,'sub*']);
dirn=length(dirlist);

if ~exist(tar,'dir')==1
    mkdir(tar);
end

w=224;
h=224;
echon = 5;
slicen = 128;
TE = [5.0, 12.0, 19.0, 26.0, 33.0]*1e-3;
minimum = 0;
maxT2 = 0.5;

%%
for loopdir=1:dirn
    tarsub = [tar,dirlist(loopdir).name,'/'];
    if ~exist(tarsub,'dir')==1
        mkdir(tarsub);
    end
    dir_fn1 = [file_path,dirlist(loopdir).name,'/scan_01/'];
    dir_fn2 = [file_path,dirlist(loopdir).name,'/scan_02/'];
    
    filelist1 = dir([dir_fn1,'*M.nii']);
    filelist2 = dir([dir_fn2,'*M.nii']);

    filen = length(filelist1);
    
    % scan 1
    indata1 = zeros(w,h,slicen,echon);
    for filei = 1:filen
        filename = [dir_fn1,filelist1(filei).name];
        data = double(load_untouch_nii(filename).img);
        indata1(:,:,:,filei) = data;
    end
    
    T2star_map = zeros(w,h,slicen);
    parfor i=1:slicen
        MASK =  indata1(:,:,i,1);
        MASK = MASK./max(MASK(:));
        level = 0.05;
        MASK = im2bw(MASK,level);
        indatafit=squeeze(indata1(:,:,i,:));
        [Map ~] = T2Map(indatafit, TE, minimum, maxT2, 0 );
        T2star_map(:,:,i)=Map(:,:,2).*MASK;
        disp(['Finished slice ',num2str(i)]);
    end
    file_out1 = [tarsub,'/scan_01_t2star.mat'];
    save(file_out1,"T2star_map");

    % scan 2
    indata2 = zeros(w,h,slicen,echon);
    for filei = 1:filen
        filename = [dir_fn2,filelist2(filei).name];
        data = double(load_untouch_nii(filename).img);
        indata2(:,:,:,filei) = data;
    end

    T2star_map = zeros(w,h,slicen);
    parfor i=1:slicen
        MASK =  indata2(:,:,i,1);
        MASK = MASK./max(MASK(:));
        level = 0.05;
        MASK = im2bw(MASK,level);
        indatafit=squeeze(indata2(:,:,i,:));
        [Map ~] = T2Map(indatafit, TE, minimum, maxT2, 0 );
        T2star_map(:,:,i)=Map(:,:,2).*MASK;
        disp(['Finished slice ',num2str(i)]);
    end
    file_out2 = [tarsub,'/scan_02_t2star.mat'];
    save(file_out2,"T2star_map");

    disp(loopdir);
end
