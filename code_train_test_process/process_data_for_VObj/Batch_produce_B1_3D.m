tar='Field_B1_256/';
num=144;

for i=1:num
    tarname=[tar,num2str(i,'%03d'),'.mat'];
    inhomo=1500;%Hz
    GAMAR=267522120;
    bandwidth=2*3.1415926*inhomo/GAMAR;
    w=256;
    h=256;
    c=160;
    Scale=bandwidth;
    Mxdims=[w,h,c];
    XDimRes=w;
    YDimRes=h;
    ZDimRes=c;
    [xgrid,ygrid,zgrid]=meshgrid((-(Mxdims(2)-1)/2)*XDimRes:XDimRes:((Mxdims(2)-1)/2)*XDimRes,...
        (-(Mxdims(1)-1)/2)*YDimRes:YDimRes:((Mxdims(1)-1)/2)*YDimRes,...
        (-(Mxdims(3)-1)/2)*ZDimRes:ZDimRes:((Mxdims(3)-1)/2)*ZDimRes);
    dB0=zeros(w,h,c);
    %% aX+bY+cZ+d
    GradX=1.0*randi(10000)/10000-0.5;
    GradY=1.0*randi(10000)/10000-0.5;
    GradZ=1.0*randi(10000)/10000-0.5;
    dB0t=(xgrid.*GradX+ygrid.*GradY+zgrid.*GradZ).*Scale;
    dB0=dB0t;

    %% XYZ
    xishu_rand = 1.0*randi(10000)/10000-0.5;
    dB0t=Scale*xishu_rand.*xgrid.*ygrid.*zgrid;
    dB0=dB0+dB0t;

    %% XY
    xishu_rand = 1.0*randi(10000)/10000-0.5;
    dB0t=Scale*xishu_rand.*xgrid.*ygrid;
    dB0=dB0+dB0t;

    xishu_rand = 1.0*randi(10000)/10000-0.5;
    dB0t=Scale*xishu_rand.*xgrid.*zgrid;
    dB0=dB0+dB0t;

    xishu_rand = 1.0*randi(10000)/10000-0.5;
    dB0t=Scale*xishu_rand.*ygrid.*zgrid;
    dB0=dB0+dB0t;

    %% X^2
    xishu_rand = 1.0*randi(10000)/10000-0.5;
    dB0t=Scale*xishu_rand.*xgrid.^2;
    dB0=dB0+dB0t;

    xishu_rand = 1.0*randi(10000)/10000-0.5;
    dB0t=Scale*xishu_rand.*ygrid.^2;
    dB0=dB0+dB0t;

    xishu_rand = 1.0*randi(10000)/10000-0.5;
    dB0t=Scale*xishu_rand.*zgrid.^2;
    dB0=dB0+dB0t;

    %% X*Y^2
    xishu_rand = 1.0*randi(10000)/10000-0.5;
    dB0t=Scale*xishu_rand.*(ygrid.*xgrid.^2);
    dB0=dB0+dB0t;
    %
    xishu_rand = 1.0*randi(10000)/10000-0.5;
    dB0t=Scale*xishu_rand.*(zgrid.*xgrid.^2);
    dB0=dB0+dB0t;
    %
    xishu_rand = 1.0*randi(10000)/10000-0.5;
    dB0t=Scale*xishu_rand.*(zgrid.*ygrid.^2);
    dB0=dB0+dB0t;
    %
    xishu_rand = 1.0*randi(10000)/10000-0.5;
    dB0t=Scale*xishu_rand.*(xgrid.*ygrid.^2);
    dB0=dB0+dB0t;
    %
    xishu_rand = 1.0*randi(10000)/10000-0.5;
    dB0t=Scale*xishu_rand.*(xgrid.*zgrid.^2);
    dB0=dB0+dB0t;
    %
    xishu_rand = 1.0*randi(10000)/10000-0.5;
    dB0t=Scale*xishu_rand.*(ygrid.*zgrid.^2);
    dB0=dB0+dB0t;
    dB0=dB0/0.3e14;

    %% Gauss3
    rand_x = randi([fix(XDimRes/3),fix(XDimRes-XDimRes/3)],1);
    rand_y = randi([fix(YDimRes/3),fix(YDimRes-YDimRes/3)],1);
    rand_z = randi([fix(ZDimRes/3),fix(ZDimRes-ZDimRes/3)],1);

    PosX = (rand_x-XDimRes/2)*XDimRes;
    PosY = (rand_y-YDimRes/2)*YDimRes;
    PosZ = (rand_z-ZDimRes/2)*ZDimRes;

    DeltaX=XDimRes*randi([25,40],1);
    DeltaY=YDimRes*randi([25,40],1);
    DeltaZ=ZDimRes*randi([20,30],1);

    Scale=(1-rand()*5e-1)*bandwidth;
    dB0t3=exp(-1.*((xgrid-PosX).^2/(2*DeltaX^2)+(ygrid-PosY).^2/(2*DeltaY^2)+(zgrid-PosZ).^2/(2*DeltaZ^2))).*Scale;

    if rand()>0.7
        a1=-1;
    else
        a1=1;
    end

    B1=dB0+a1.*dB0t3./1.8;
    B1=B1./max(abs(B1(:)));
    B1=B1*0.32+1;
    B1=B1*(rand()*0.08+0.92);
    save(tarname,'B1');
    disp(tarname);
end