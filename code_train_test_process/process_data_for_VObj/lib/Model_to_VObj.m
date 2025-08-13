% generate VObj for SMRI/MRiLab simulation

function out_obj = Model_to_VObj(t1,t2,m0,loc,qsm,b0,b1,target_path)
warning ('off')

row = 512;  
col = 512;
fov = 0.44;

%
VObj.XDim = row;
VObj.YDim = col;
VObj.ZDim = 1;
VObj.XDimRes = fov/row;
VObj.YDimRes = fov/col;
VObj.ZDimRes=1e-3;

%%
VObj.Rho = single(abs(m0));
VObj.T1 = single(abs(t1));
VObj.T2 = single(abs(t2));
VObj.T2Star = single(abs(t2).*0.9);
VObj.B0loc = single(loc);
VObj.Sus = single(qsm);
VObj.B1 = single(b1);
VObj.B0 = single(b0);

VObj.ECon = [];
VObj.MassDen = [];
out_obj = VObj;

save_file = [target_path,num2str(a)];
disp(save_file);
save(save_file,'VObj')
end
