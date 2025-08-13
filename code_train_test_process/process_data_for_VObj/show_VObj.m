close all;

addpath(genpath('tools'));
load('code_train_test_process/demo_VObj/1.mat');

figure(1);
set(gcf,'Color','w');

ha = tight_subplot(2,4,[0.02 0.02],[0.02 0.02],[0.02 0.02]);

axes(ha(1));
imshow(rot90(VObj.T1,3),[0 3.5]);colormap(ha(1), jet);
title('VObj T1 map (s)','FontSize', 16, 'FontWeight', 'bold');colorbar;
axis off;

axes(ha(2));
imshow(rot90(VObj.T2,3),[0 0.2]),colormap(ha(2), jet);
title('VObj T2star map (s)','FontSize', 16, 'FontWeight', 'bold');colorbar;
axis off;

axes(ha(3));
imshow(rot90(VObj.Rho,3),[0 1]),colormap(ha(3), gray);
title('VObj M0 map (a.u.)','FontSize', 16, 'FontWeight', 'bold');colorbar;
axis off;

axes(ha(4));
imshow(rot90(VObj.Sus,3),[-0.1 0.1]),colormap(ha(4), gray);
title('VObj QSM (ppm)','FontSize', 16, 'FontWeight', 'bold');colorbar;
axis off;

axes(ha(5));
imshow(rot90(VObj.B0loc,3),[-5 5]),colormap(ha(5), gray);
title('VObj B0loc (Hz)','FontSize', 16, 'FontWeight', 'bold');colorbar;
axis off;

axes(ha(6));
imshow(rot90(VObj.B0,3),[-120 120]),colormap(ha(6), hot);
title('VObj B0bg map (Hz)','FontSize', 16, 'FontWeight', 'bold');colorbar;
axis off;

axes(ha(7));
imshow(rot90(VObj.B1,3),[0.7 1.3]),colormap(ha(7), parula);
title('VObj B1 map (a.u.)','FontSize', 16, 'FontWeight', 'bold');colorbar;
axis off;

axes(ha(8));
axis off;