clear;clc;
addpath(genpath('tools'));

srcUrl = 'code_train_test_process/demo_SMRI_out/1.out';

h=224;
w=216;

echon=2;
shotn=8;
ETL=27;

alldata = SMri2D_reader(srcUrl, h, ETL);
alldata = squeeze(alldata(1,:,:,:)) +1i* squeeze(alldata(2,:,:,:)); 
alldata = reshape(alldata,[h,ETL,echon,shotn]);

ksp = zeros(h,ETL*shotn,echon);
for echoi=1:echon
    for shoti=1:shotn
        mshotdata=alldata(:,:,echoi,shoti);
        mshotdata(:,2:2:end) = flipud(mshotdata(:,2:2:end));
        ksp(:,shoti:shotn:end,echoi)=mshotdata;
    end
end

ksp_echo1 = ifft2c(ksp(:,:,1));
ksp_echo2 = ifft2c(rot90(ksp(:,:,2),2));

cupnorm = max(abs(ksp_echo1(:)));
ksp_img1 = fft2c(ksp_echo1 ./ cupnorm);
ksp_img2 = fft2c(ksp_echo2 ./ cupnorm);

temp = zeros(h,h);temp(:,5:end-4)=ksp_img1;
k1_image = ifft2c(temp);

temp = zeros(h,h);temp(:,5:end-4)=ksp_img2;
k2_image = ifft2c(temp);

figure(1);
imshow(abs([abs(k1_image) abs(k2_image)]),[0 0.7]);

figure(2);
imshow(abs([fft2c(k1_image) fft2c(k2_image)]),[0 0.7]);