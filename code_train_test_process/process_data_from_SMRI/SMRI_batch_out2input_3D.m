clear;clc;
addpath(genpath('tools'));

srcUrl = 'scan/';
vobjUrl = 'Template_SMRI_3DMOLED/';
dstUrl = 'Deep_Learning_3D_MOLED/dataset_demo/train/';
topname='train_3D_';
mkdir(dstUrl);

echon=2;
shotn=8;
ETL=27;
h=224;
w=216;

cupnorm=300;

EXPAND_NUM = 224;
gy=2.67519e8;
pi=3.14159265359;

start_index = 1;
end_index =1;
slicen=110;

k1_max3norm = 0.08;

for index = start_index:end_index

    t2star=zeros(1,h,h,slicen);
    qsm=zeros(1,h,h,slicen);

    oled_temp1=zeros(h,h,slicen);
    oled_temp2=zeros(h,h,slicen);
    oled=zeros(4,h,h,slicen);

    parfor slicei=1:slicen

        FRE_NUM = 224;
        PHASE_NUM = 216;
        h=224;
        w=216;
        
        echon=2;
        shotn=8;
        ETL=27;

        order = (index-1)*slicen+slicei;

        srcName = sprintf("%d.out", order);
        vobjName = sprintf("%d.mat", order);

        srcPath = fullfile(srcUrl, srcName);
        vobjPath = fullfile(vobjUrl, vobjName);

        temp = load(vobjPath);
        VObj = temp.VObj;
        EXPAND_NUM = 224;

        T2 = VObj.T2;
        T2 = abs(imresize(T2,[EXPAND_NUM, EXPAND_NUM],'nearest'));
        T2 = rot90(T2,1);
        T2(T2>0.3)=0.3;

        sus = VObj.Sus;
        sus = imresize(sus,[EXPAND_NUM, EXPAND_NUM],'nearest');
        sus = rot90(sus,1);

        alldata = SMri2D_reader(srcPath, h, ETL);
        alldata = squeeze(alldata(1,:,:,:)) +1i* squeeze(alldata(2,:,:,:)); % 224 107 4
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

        ksp_img1 = fft2c(ksp_echo1 ./ cupnorm);
        ksp_img2 = fft2c(ksp_echo2 ./ cupnorm);

        temp = zeros(h,h);temp(:,5:end-4)=ksp_img1;
        k1_image = ifft2c(temp);

        temp = zeros(h,h);temp(:,5:end-4)=ksp_img2;
        k2_image = ifft2c(temp);

        t2star(1,:,:,slicei)=T2;
        qsm(1,:,:,slicei)=sus;
        oled_temp1(:,:,slicei)=k1_image;
        oled_temp2(:,:,slicei)=k2_image;

        disp(['Slice: ',num2str(slicei)]);
        order=order+1;
    end

    cup = max(abs(oled_temp1(:)));
    ratio = cup./1;

    % add noise
    sigma = 0.02 * rand(1) .* ratio;

    ksp_noise = sigma * randn(h, h, slicen) + 1.0i * sigma * randn(h, h, slicen);
    oled_temp1 = oled_temp1 + ksp_noise;

    ksp_noise = sigma * randn(h, h, slicen) + 1.0i * sigma * randn(h, h, slicen);
    oled_temp2 = oled_temp2 + ksp_noise;

    oled(1,:,:,:)=real(oled_temp1);
    oled(2,:,:,:)=imag(oled_temp1);
    oled(3,:,:,:)=real(oled_temp2);
    oled(4,:,:,:)=imag(oled_temp2);

    t2star=single(t2star);
    qsm=single(qsm);
    oled=single(oled);

    if sum(isnan(oled(:)))>0
        disp('error');
    else
        save_name = [dstUrl,topname,num2str(index,'%04d'),'.mat'];
        disp(save_name);
        save(save_name,'t2star','qsm','oled');
    end
end