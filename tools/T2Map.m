function Map = T2Map(indata, tes, minimum, maxT2)
rows = size(indata,1);
cols = size(indata,2);
N    = size(indata,3);
ly   = length(tes);
tes = reshape(tes, ly, 1); 
 
Map = zeros(rows,cols,2); 
Map(:,:,:) = 0;
tes = [ones(ly,1), tes]; 
    
indata = abs(indata);
 
thresh = sum( (abs(indata(:,:,:)) > minimum), 3) > (N-1);
 
inData = abs(indata); 
 
SkippedPixels = 0;
 
minR2 = 1/maxT2;

AvgCutoff = minimum * sqrt(ly); 
for r=1:rows
    for c=1:cols
        ydata = inData(r,c,:);
        ydata = reshape(ydata,N,1);
        if thresh(r,c) && ( mean(ydata) > AvgCutoff )
            lfit = tes \ log(ydata);
            if( lfit(2) < 0 && -lfit(2) > minR2 )
                Map(r,c,1) = lfit(1);
                Map(r,c,2) = -1/lfit(2);
            elseif(-lfit(2) < minR2)
                Map(r,c,1) = lfit(1);
                Map(r,c,2) = maxT2;
            else
                thresh(r,c) = 0;
                SkippedPixels = SkippedPixels + 1;
            end
        else
            thresh(r,c) = 0;
            SkippedPixels = SkippedPixels + 1;
        end
    end
end 
 
Map(:,:,1) = exp(Map(:,:,1));
 