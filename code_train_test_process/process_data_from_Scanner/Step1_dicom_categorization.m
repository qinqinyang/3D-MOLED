clear;
clc;
fn='sub01/';
fn_name='DICOM';
source_fn=[fn,fn_name,'/'];
target_fn=[fn,fn_name,'_output/'];

if ~exist(target_fn,'dir')==1
    mkdir(target_fn);
end

file_list=dir([source_fn,'IM*']);
file_n=length(file_list);

parfor i=1:file_n
    file_fn=[source_fn,file_list(i).name];
    info=dicominfo(file_fn);
    sequence=info.SeriesDescription;
    sequence=strrep(sequence,'*','_');
    sequence=strrep(sequence,':','_');
    sequence=strrep(sequence,' ','_');
    seq_id=sequence(1);
    if seq_id=='<'
       sequence=sequence(2:end-1);
    end
    
    sequence_dir=[target_fn,sequence,'\'];
    %disp(sequence_dir);
    if ~exist(sequence_dir,'dir')==1
        mkdir(sequence_dir);
    end
    
    file_fn_tar=[sequence_dir,file_list(i).name,'.dcm'];
    copyfile(file_fn,file_fn_tar);
    disp(file_fn);
end
