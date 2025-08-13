%%
% Convert the results in MAT format to DICOM, and 
% Then use MRIconvert to convert them to NIfTI (NII) format for registration and analysis.

%% Batch mat2dcm for 3D-MOLED T2star
clc;
clear all;
path_dicom='Data_3D_OLED_dicom/';alldicompath=dir([path_dicom,'sub*']);
path_mat='Data_3D_OLED_t2star/'; allmatpath=dir([path_mat,'sub*']);
out_path='T2star_dcm/';
name1='OLED_3D_SENSE2_0';
for i=1:3
    for j=1:2
        meta_path=[path_dicom,alldicompath(i).name,'\',name1,num2str(j),'\']
        meta_indexpath=dir([meta_path,'*.dcm']);

        result_path=[path_mat,allmatpath(i).name,'\',name1,num2str(j),allmatpath(i).name(6:end),'_t2star.mat']

        output_path=[out_path,allmatpath(i).name,'_',num2str(j),'\'];  mkdir(output_path);

        load(result_path);
        slices=size(output,3);
        mkdir(output_path)
        for slice=1:slices
            metadata=dicominfo([meta_path,meta_indexpath(2*slice-1).name]);
            temp=(fliplr(flipud(rot90(uint16(1000*output(:,:,slice))))));
            % temp=imresize(temp,[224,216]);
            out_indexpath=[output_path,'layer_',num2str(slice),'.dcm'];
            dicomwrite(temp, out_indexpath,metadata);
            disp(out_indexpath);
        end
    end
end

%% Batch mat2dcm for 3D-MOLED QSM
clc;
clear all;
path_dicom='Data_3D_OLED_dicom/';alldicompath=dir([path_dicom,'sub*']);
path_mat='Data_3D_OLED_QSM/'; allmatpath=dir([path_mat,'sub*']);
out_path='QSM_dcm/';
name1='OLED_3D_SENSE2_0';
echo=2;
for i=1:3
    for j=1:2
        meta_path=[path_dicom,alldicompath(i).name,'\',name1,num2str(j),'\']
        meta_indexpath=dir([meta_path,'*.dcm']);

        result_path=[path_mat,allmatpath(i).name,'\',name1,num2str(j),allmatpath(i).name(6:end),'_qsm.mat']

        output_path=[out_path,allmatpath(i).name,'_',num2str(j),'\'];  mkdir(output_path);

        load(result_path);
        slices=size(output,3);
        mkdir(output_path)
        for slice=1:slices
            metadata=dicominfo([meta_path,meta_indexpath(echo*slice-1).name]);
            temp=(fliplr(flipud(rot90(uint16(1000*(output(:,:,slice)+1))))));
            % temp=imresize(temp,[224,216]);
            out_indexpath=[output_path,'layer_',num2str(slice),'.dcm'];
            dicomwrite(temp, out_indexpath,metadata);
            disp(out_indexpath);
        end
    end
end

%% Batch mat2dcm for 3D-GRE T2star
clc;
clear all;
path_dicom='Data_3D_GRE_dicom/';alldicompath=dir([path_dicom,'sub*']);
path_mat='Data_3D_GRE_t2star/'; allmatpath=dir([path_mat,'sub*']);
out_path='GRE_T2star_dcm/';
name1='QSM_Echo5_CS3_0';
echo=5;
for i=1:3
    for j=1:2
        meta_path=[path_dicom,alldicompath(i).name,'\',name1,num2str(j),'\']
        meta_indexpath=dir([meta_path,'*.dcm']);

        result_path=[path_mat,allmatpath(i).name,'\','scan_0',num2str(j),'_t2star.mat']

        output_path=[out_path,allmatpath(i).name,'_',num2str(j),'\'];  mkdir(output_path);

        load(result_path);
        slices=size(T2star_map,3);
        for slice=1:slices
            metadata=dicominfo([meta_path,meta_indexpath(echo*slice-1).name]);
            temp=(((rot90(uint16(1000*(T2star_map(:,:,slice)))))));
            % temp=imresize(temp,[224,216]);
            metadata.WindowCenter=100;
            metadata.WindowWidth=200;
            out_indexpath=[output_path,'layer_',num2str(slice),'.dcm'];
            dicomwrite(temp, out_indexpath,metadata);
            disp(out_indexpath);
        end
    end
end

%% Batch mat2dcm for 3D-GRE QSM
clc;
clear all;
path_dicom='Data_3D_GRE_dicom/';alldicompath=dir([path_dicom,'sub*']);
path_mat='Data_3D_GRE_QSM/'; allmatpath=dir([path_mat,'sub*']);
out_path='GRE_qsm_dcm/';
name1='QSM_Echo5_CS3_0';
echo=5;
for i=1:3
    for j=1:2
        meta_path=[path_dicom,alldicompath(i).name,'\',name1,num2str(j),'\']
        meta_indexpath=dir([meta_path,'*.dcm']);

        result_path=[path_mat,allmatpath(i).name,'\','scan_0',num2str(j),'_qsm.mat']

        output_path=[out_path,allmatpath(i).name,'_',num2str(j),'\'];  mkdir(output_path);

        load(result_path);
        slices=size(qsm,3);

        for slice=1:slices
            metadata=dicominfo([meta_path,meta_indexpath(echo*slice-1).name]);
            temp=(((rot90(uint16(1000*((qsm(:,:,slice)+1)))))));
            % temp=imresize(temp,[224,216]);
            metadata.WindowCenter=1000;
            metadata.WindowWidth=2000;
            out_indexpath=[output_path,'layer_',num2str(slice),'.dcm'];
            dicomwrite(temp, out_indexpath,metadata);
            disp(out_indexpath);
        end
    end
end

