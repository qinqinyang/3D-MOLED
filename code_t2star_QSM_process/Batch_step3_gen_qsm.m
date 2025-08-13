%% load raw data
clc;
clear;
addpath(genpath('tools'));

file_path = 'Data/';
mask_path = 'Data_mask_echo4/';
tar='Data_3D_GRE_QSM/';

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
%%
for loopdir=1:dirn
    tarsub = [tar,dirlist(loopdir).name,'/'];
    if ~exist(tarsub,'dir')==1
        mkdir(tarsub);
    end
    dir_fn1 = [file_path,dirlist(loopdir).name,'/scan_01/'];
    dir_fn1_mask = [mask_path,dirlist(loopdir).name,'/scan_01_mask_mask.nii.gz'];

    dir_fn2 = [file_path,dirlist(loopdir).name,'/scan_02/'];
    dir_fn2_mask = [mask_path,dirlist(loopdir).name,'/scan_02_mask_mask.nii.gz'];
    
    filelist1 = dir([dir_fn1,'*P.nii']);
    filelist2 = dir([dir_fn2,'*P.nii']);

    filen = length(filelist1);

    % scan 1
    indata1 = zeros(w,h,slicen,echon);
    parfor filei = 1:filen
        filename = [dir_fn1,filelist1(filei).name];
        temp = double(load_untouch_nii(filename).img);
        pmin=min(temp(:));
        temp=temp+pmin;
        temp=temp./max(temp(:));
        indata1(:,:,:,filei)=temp*2*pi-pi;
    end

    [qsm,newmask] = cal_QSM(indata1,dir_fn1_mask);
    file_out1 = [tarsub,'/scan_01_qsm.mat'];
    save(file_out1,"qsm","newmask");

    % scan 2
    indata2 = zeros(w,h,slicen,echon);
    parfor filei = 1:filen
        filename = [dir_fn2,filelist2(filei).name];
        temp = double(load_untouch_nii(filename).img);
        pmin=min(temp(:));
        temp=temp+pmin;
        temp=temp./max(temp(:));
        indata2(:,:,:,filei)=temp*2*pi-pi;
    end

    [qsm,newmask] = cal_QSM(indata2,dir_fn2_mask);
    file_out2 = [tarsub,'/scan_02_qsm.mat'];
    save(file_out2,"qsm","newmask");

    disp(file_out2);
end

function [Susceptibility,NewMask] = cal_QSM(data,mask_path)
echon = 5;
TE = [5.0, 12.0, 19.0, 26.0, 33.0]*1e-3;
Pha=data;

mask1=load_untouch_nii(mask_path).img;

% Phase unwarp
voxelsize=[1 1 1];
padsize=[3 3 3];
[Unwrapped_Phase, Laplacian]=MRPhaseUnwrap(Pha,'voxelsize',voxelsize,'padsize',padsize);

% local field estimate
voxelsize=[1 1 1];
smvsize =10;
B0=3;
Gy=2.67519e8;
TissuePhase=zeros(size(Unwrapped_Phase));
for echoi=1:echon
    [TissuePhase(:,:,:,echoi),NewMask]=V_SHARP(Unwrapped_Phase(:,:,:,echoi),mask1,'voxelsize',voxelsize,'smvsize',smvsize);
    TissuePhase(:,:,:,echoi)=TissuePhase(:,:,:,echoi)./(Gy*TE(echoi)*B0);
end
local_field_ppm = mean(TissuePhase,4)*1e6;

% QSM iLSQR
H=[0 0 1];
voxelsize=[1 1 1];
padsize=[3 3 3];

[Susceptibility]= QSM_iLSQR(local_field_ppm,NewMask,'B0',B0,'H',H,'padsize',padsize,'voxelsize',voxelsize);
end
