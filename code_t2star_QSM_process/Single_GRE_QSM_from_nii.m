%% load raw data
clc;
clear;
addpath(genpath('tools'));

fn='sub02_GRE_nii\';
dirlist=dir([fn,'*P.nii']);

path_mask='sub02_GRE_nii\GRE_mask.nii';
mask=load_untouch_nii(path_mask).img;

% ---------- Parameters ----------
w=224;
h=224;
slicen=128;
echon=5;
vsize = [1.0, 1.0, 1.0];
TE=[5, 12, 19, 26, 33]*0.001;

data=zeros(w,h,slicen,echon);

for echoi=1:echon
    filename=[fn,dirlist(echoi).name];
    disp(filename);
    temp=double(load_untouch_nii(filename).img);
    pmin=min(temp(:));
    temp=temp+pmin;
    temp=temp./max(temp(:));
    data(:,:,:,echoi)=temp*2*pi-pi;
end

% ---------- Phase unwarp ----------
padsize=[3 3 3];
[Unwrapped_Phase, Laplacian]=MRPhaseUnwrap(data,'voxelsize',vsize,'padsize',padsize);

% ---------- local field estimation ---------- 
smvsize =10;
B0=3;
Gy=2.67519e8;
TissuePhase=zeros(size(Unwrapped_Phase));
for echoi=1:echon
    [TissuePhase(:,:,:,echoi),NewMask]=V_SHARP(Unwrapped_Phase(:,:,:,echoi),mask,'voxelsize',vsize,'smvsize',smvsize);
    TissuePhase(:,:,:,echoi)=TissuePhase(:,:,:,echoi)./(Gy*TE(echoi)*B0);
end
local_field_ppm = mean(TissuePhase,4)*1e6;

% ---------- QSM iLSQR ----------  
H=[0 0 1];
padsize=[3 3 3];
[Susceptibility]= QSM_iLSQR(local_field_ppm,NewMask,'B0',B0,'H',H,'padsize',padsize,'voxelsize',vsize);

% ---------- Display results ----------
figure;
imshow3(Susceptibility,[-0.1 0.1]); % unit ppm
