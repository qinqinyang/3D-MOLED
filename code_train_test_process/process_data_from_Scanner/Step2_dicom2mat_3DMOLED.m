clear,clc;
fn='MOLED_3D_SENSE2_dcm/';
tar='MOLED_3D_SENSE2_mat/';

if ~exist(tar,'dir')==1
    mkdir(tar);
end

filelist=dir([fn,'*.dcm']);


w=224;
h=224;
slicen=128;
echon=2;

for ii=1:slicen
    current_out = zeros(w, h, echon);

    filename1=[fn,filelist((ii*2)-1).name];
    filename2=[fn,filelist((ii)*2).name];

    filename1p=[fn,filelist(slicen*2+(ii*2)-1).name];
    filename2p=[fn,filelist(slicen*2+(ii)*2).name];

    im1=double(dicomread(filename1));
    ph1=double(dicomread(filename1p));

    %cup1=max(im1(:))
    cup1=800;
    cup2=4095;

    im1=im1./cup1;
    ph1=ph1./cup2;
    
    ph1=ph1*2*pi-pi;
    data1=abs(im1).*exp(-1i*ph1);

    im2=double(dicomread(filename2));
    ph2=double(dicomread(filename2p));

    im2=im2./cup1;
    ph2=ph2./cup2;
    ph2=ph2*2*pi-pi;
    data2=abs(im2).*exp(-1i*ph2);

    current_out(:,:,1) = data1;
    current_out(:,:,2) = data2;

    save_name = [tar,'brain_',num2str(ii,'%03d'),'.mat'];

    save(save_name,'current_out');
    disp(save_name);
end
