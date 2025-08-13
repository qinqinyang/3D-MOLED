
clc;
clear;

w=224;
h=224;

total_channel=4;
slicen=128;

fn = 'sub01/';

fname='MOLED_3D_SENSE2_mat';
tarname='MOLED_3D_SENSE2_mat_3D';

infn=[fn,fname,'/'];
target=[fn,fname,'_3D/'];

if ~exist(target,'dir')==1
    mkdir(target);
end

in_list=dir([infn,'*.mat']);

oled=zeros(total_channel,w,h,slicen);

for jj=1:slicen
    idx=jj;
    read_fn=[infn,in_list(jj).name];
    load(read_fn);
    temp = fft2c(current_out);
    img = ifft2c(rot90(temp,1));

    oled(1,:,:,idx)=real(img(:,:,1));
    oled(2,:,:,idx)=imag(img(:,:,1));
    oled(3,:,:,idx)=real(img(:,:,2));
    oled(4,:,:,idx)=imag(img(:,:,2));
    disp(['Slice: ',num2str(jj)]);
end

tarname=[target,tarname,'.mat'];
save(tarname,'oled');
disp('finished!');
