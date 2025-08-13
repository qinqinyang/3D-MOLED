clc; clear;
addpath(genpath('tools'));

fn='QSM_Echo5_CS3/';
filelist=dir([fn,'IM*']);

% ---------- Parameters ----------
w=224;
h=224;
slicen=128;
ten=5;

minimum = 0;
maxT2 = 0.5;
level = 0.05;

tes=zeros(1,ten);
indata=zeros(w,h,ten,slicen);
T2star_map=zeros(w,h,slicen);
mask = zeros(w,h,slicen);
M0_map=zeros(w,h,slicen);

% ---------- Collect and sort DICOM files ----------
for slicei=1:slicen
    index=(slicei-1)*ten;
    for tei=1:ten
        filename=[fn,filelist(index+tei).name];
        II=double(dicomread(filename));
        info = dicominfo(filename);
        indata(:,:,tei,slicei) = II;
        if slicei==1
            tes(tei) = info.EchoTime*1e-3;
        end
    end
    disp(['Read slice ',num2str(slicei)]);
end

% ---------- T2* fitting (per slice) ----------
for i=1:slicen
    MASK =  indata(:,:,1,i);
    MASK = MASK./max(MASK(:));
    MASK = im2bw(MASK,level);
    indatafit=indata(:,:,:,i);
    Map = T2Map(indatafit, tes, minimum, maxT2);
    M0_map(:,:,i)=Map(:,:,1).*MASK;
    T2star_map(:,:,i)=Map(:,:,2).*MASK;
    mask(:,:,i) = MASK;
    disp(['Finished slice ',num2str(i)]);
end

% ---------- Display results ----------
figure;
imshow3(T2star_map,[0 0.2]),colormap jet;