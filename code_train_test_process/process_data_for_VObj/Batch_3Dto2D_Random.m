clear;clc;
fn='data/';
tar='Template_SMRI_niubi_3D/';
mkdir(tar);

fn_T1=[fn,'Trans_T1_256/'];
fn_T2=[fn,'Trans_T2_256/'];
fn_M0=[fn,'Trans_M0_256/'];
fn_QSM=[fn,'Raw_QSM_256/'];
fn_B1=[fn,'Field_B1_256/'];

subn=144;
order=1;
transform=1;

for subi=1:subn
    % load data
    idxname=num2str(subi,'%03d');
    fn_T1_file=[fn_T1,idxname,'.mat'];load(fn_T1_file);
    fn_T2_file=[fn_T2,idxname,'.mat'];load(fn_T2_file);
    fn_M0_file=[fn_M0,idxname,'.mat'];load(fn_M0_file);
    fn_QSM_file=[fn_QSM,'QSM_',idxname,'.mat'];load(fn_QSM_file);
    fn_B1_file=[fn_B1,idxname,'.mat'];load(fn_B1_file);

    % random rotate
    rotidx=randi([1,4],1,1);
    T1_map=rot90(T1_map,rotidx);
    T2_map=rot90(T2_map,rotidx);
    M0_map=rot90(M0_map,rotidx);
    QSM=rot90(QSM,rotidx);

    % random scaling
    if transform == 1
        rand_T2=unifrnd(0.90,1.2);
        rand_T1=unifrnd(0.90,1.2);
        rand_M0=unifrnd(0.90,1.2);
        rand_QSM=unifrnd(0.90,2.0);

        T1_map=T1_map.*rand_T1;
        T2_map=T2_map.*rand_T2;
        M0_map=M0_map.*rand_M0;
        QSM=QSM.*rand_QSM;
    end

    % QSM to Phase
    vox=[1,1,1];
    B0=3;
    Gy=2.67519e8;
    [field, ~] = forward_field_calc(QSM, vox, [0 0 1], 0);
    B0loc = field*1e-6*B0*Gy./(2*pi);

    % Source to B0 field
    bkg = PhanGene(QSM, 50, 300);
    mask = M0_map ~= 0;
    mask = double(mask);
    bkg = bkg .* (~mask);
    dB0= forward_field_calc(bkg, vox, [0 0 1], 1).* mask;

    % Resize to 512*512
    T1_map=imresize3(T1_map,[512,512,160]);
    T2_map=imresize3(T2_map,[512,512,160]);
    M0_map=imresize3(M0_map,[512,512,160]);
    dB0=imresize3(dB0,[512,512,160]);
    B1=imresize3(B1,[512,512,160]);
    B0loc=imresize3(B0loc,[512,512,160]);

    % Mask
    m_t1=zeros(size(T1_map));m_t1(T1_map>0.005)=1;
    m_t2=zeros(size(T2_map));m_t2(T2_map>0.005)=1;
    m_m0=zeros(size(M0_map));m_m0(M0_map>0.005)=1;
    mask=double(m_t1&m_t2&m_t2star&m_m0);
    B1=B1.*mask;
    dB0=dB0.*mask;
    T1_map=T1_map.*mask;
    T2_map=T2_map.*mask;
    M0_map=M0_map.*mask;

    % 3D to 2D VObj
    for slicei=31:140
        t1=T1_map(:,:,slicei);
        t2=T2_map(:,:,slicei);
        m0=M0_map(:,:,slicei);
        sus=QSM(:,:,slicei);
        b0loc=B0loc(:,:,slicei);
        b0=dB0(:,:,slicei);
        b1=B1(:,:,slicei);

        % to VObj
        Model_to_VObj(t1,t2,m0,b0loc,sus,b0,b1,tar);
        order=order+1;
    end
end