function [xtable ytable utable vtable typevector] =...
         piv_FFTmulti (image1,image2,interrogationarea, step,...
         subpixfinder, mask_inpt, roi_inpt,passes,...
         int2,int3,int4,imdeform,non_poly_mask_inpt)
     
if nargin < 13     
    non_poly_mask_inpt = [];
end
     
%profile on
%this funtion performs the  PIV analysis.
warning off %#ok<*WNOFF> %MATLAB:log:logOfZero
if numel(roi_inpt)>0
    xroi=roi_inpt(1);
    yroi=roi_inpt(2);
    widthroi=roi_inpt(3);
    heightroi=roi_inpt(4);
    image1_roi=double(image1(yroi:yroi+heightroi,xroi:xroi+widthroi));
    image2_roi=double(image2(yroi:yroi+heightroi,xroi:xroi+widthroi));
else
    xroi=0;
    yroi=0;
    image1_roi=double(image1);
    image2_roi=double(image2);
end
if numel(mask_inpt)>0
    cellmask=mask_inpt;
    mask=zeros(size(image1_roi));
    for i=1:size(cellmask,1);
        masklayerx=cellmask{i,1};
        masklayery=cellmask{i,2};
        mask = mask + poly2mask(masklayerx-xroi,masklayery-yroi,size(image1_roi,1),size(image1_roi,2)); %kleineres eingangsbild und maske geshiftet
    end
else
    mask=zeros(size(image1_roi));
end
mask(mask>1)=1;

if numel(non_poly_mask_inpt)>0
    mask = non_poly_mask_inpt;
end
mask(mask>1)=1;


miniy=1+(ceil(interrogationarea/2));
minix=1+(ceil(interrogationarea/2));
maxiy=step*(floor(size(image1_roi,1)/step))-(interrogationarea-1)+(ceil(interrogationarea/2)); %statt size deltax von ROI nehmen
maxix=step*(floor(size(image1_roi,2)/step))-(interrogationarea-1)+(ceil(interrogationarea/2));

numelementsy=floor((maxiy-miniy)/step+1);
numelementsx=floor((maxix-minix)/step+1);

LAy=miniy;
LAx=minix;
LUy=size(image1_roi,1)-maxiy;
LUx=size(image1_roi,2)-maxix;
shift4centery=round((LUy-LAy)/2);
shift4centerx=round((LUx-LAx)/2);
if shift4centery<0 %shift4center will be negative if in the unshifted case the left border is bigger than the right border. the vectormatrix is hence not centered on the image. the matrix cannot be shifted more towards the left border because then image2_crop would have a negative index. The only way to center the matrix would be to remove a column of vectors on the right side. but then we weould have less data....
    shift4centery=0;
end
if shift4centerx<0 %shift4center will be negative if in the unshifted case the left border is bigger than the right border. the vectormatrix is hence not centered on the image. the matrix cannot be shifted more towards the left border because then image2_crop would have a negative index. The only way to center the matrix would be to remove a column of vectors on the right side. but then we weould have less data....
    shift4centerx=0;
end
miniy=miniy+shift4centery;
minix=minix+shift4centerx;
maxix=maxix+shift4centerx;
maxiy=maxiy+shift4centery;

image1_roi=padarray(image1_roi,[ceil(interrogationarea/2) ceil(interrogationarea/2)], min(min(image1_roi)));
image2_roi=padarray(image2_roi,[ceil(interrogationarea/2) ceil(interrogationarea/2)], min(min(image1_roi)));
mask=padarray(mask,[ceil(interrogationarea/2) ceil(interrogationarea/2)],0);

if (rem(interrogationarea,2) == 0) %for the subpixel displacement measurement
    SubPixOffset=1;
else
    SubPixOffset=0.5;
end
xtable=zeros(numelementsy,numelementsx);
ytable=xtable;
utable=xtable;
vtable=xtable;
typevector=ones(numelementsy,numelementsx);
%corr_results=cell(numelementsy,numelementsx);
nrx=0;
nrxreal=0;
nry=0;
increments=0;
%% MAINLOOP
try %check if used from GUI
    handles=guihandles(getappdata(0,'hgui'));
    GUI_avail=1;
catch %#ok<CTCH>
    GUI_avail=0;
end
for j = miniy:step:maxiy %vertical loop
    nry=nry+1;
    if increments<6 %reduced display refreshing rate
        increments=increments+1;
    else
        increments=1;
        if GUI_avail==1
            %passes
            set(handles.progress, 'string' , ['Frame progress: ' int2str(j/maxiy*100/passes) '%' sprintf('\n') 'pass: 1 / ' int2str(passes)]);drawnow;
        else
            fprintf('.');
        end
    end
    %n=round((j-miniy)/maxiy*100);
    for i = minix:step:maxix % horizontal loop
        nrx=nrx+1;%used to determine the pos of the vector in resulting matrix
        if nrxreal < numelementsx
            nrxreal=nrxreal+1;
        else
            nrxreal=1;
        end
        startpoint=[i j];
        
        image1_crop=image1_roi(j:j+interrogationarea-1, i:i+interrogationarea-1);
        image2_crop=image2_roi(j:j+interrogationarea-1, i:i+interrogationarea-1);
        
        if mask(round(j+interrogationarea/2),round(i+interrogationarea/2))==0
            result_conv =fftshift(real(ifft2(conj(fft2(image1_crop)).*fft2(image2_crop))));
            result_conv=result_conv/max(max(result_conv))*255; %normalize, peak=always 255
            [y,x] = find(result_conv==255); %Find the 255 peak
            if size(x,1)>1 %if there are more than 1 peaks just take the first
                x=x(1:1);
            end
            if size(y,1)>1 %if there are more than 1 peaks just take the first
                y=y(1:1);
            end
            %corr_results{nry,nrxreal}=result_conv;
            if isnan(y)==0 && isnan(x)==0
                try
                    if subpixfinder==1
                        [vector] = SUBPIXGAUSS (result_conv,interrogationarea,x,y,SubPixOffset);
                    elseif subpixfinder==2
                        [vector] = SUBPIX2DGAUSS (result_conv,interrogationarea,x,y,SubPixOffset);
                    end
                catch
                    vector=[NaN NaN]; %if something goes wrong with cross correlation.....
                end
            else
                vector=[NaN NaN]; %if something goes wrong with cross correlation.....
            end
        else %if mask was not 0 then
            vector=[NaN NaN];
            typevector(nry,nrxreal)=0;
        end
        %Create the vector matrix x, y, u, v
        xtable(nry,nrxreal)=startpoint(1)+interrogationarea/2;
        ytable(nry,:)=startpoint(1,2)+interrogationarea/2;
        utable(nry,nrxreal)=vector(1);
        vtable(nry,nrxreal)=vector(2);
    end
end

%multipass
%feststellen wie viele passes
%wenn intarea=0 dann keinen pass.
for multipass=1:passes-1
    if GUI_avail==1
        set(handles.progress, 'string' , ['Frame progress: ' int2str(j/maxiy*100/passes+((multipass-1)*(100/passes))) '%' sprintf('\n') 'Validating velocity field']);drawnow;
     else
        fprintf('.');
    end
    %multipass validation, smoothing
    %stdev test
    utable_orig=utable;
    vtable_orig=vtable;
    stdthresh=4;
    meanu=nanmean(nanmean(utable));
    meanv=nanmean(nanmean(vtable));
    std2u=nanstd(reshape(utable,size(utable,1)*size(utable,2),1));
    std2v=nanstd(reshape(vtable,size(vtable,1)*size(vtable,2),1));
    minvalu=meanu-stdthresh*std2u;
    maxvalu=meanu+stdthresh*std2u;
    minvalv=meanv-stdthresh*std2v;
    maxvalv=meanv+stdthresh*std2v;
    utable(utable<minvalu)=NaN;
    utable(utable>maxvalu)=NaN;
    vtable(vtable<minvalv)=NaN;
    vtable(vtable>maxvalv)=NaN;
    
    %median test
    %info1=[];
    epsilon=0.02;
    thresh=2;
    [J,I]=size(utable);
    %medianres=zeros(J,I);
    normfluct=zeros(J,I,2);
    b=1;
    %eps=0.1;
    for c=1:2
        if c==1; velcomp=utable;else velcomp=vtable;end
        for i=1+b:I-b
            for j=1+b:J-b
                neigh=velcomp(j-b:j+b,i-b:i+b);
                neighcol=neigh(:);
                neighcol2=[neighcol(1:(2*b+1)*b+b);neighcol((2*b+1)*b+b+2:end)];
                med=median(neighcol2);
                fluct=velcomp(j,i)-med;
                res=neighcol2-med;
                medianres=median(abs(res));
                normfluct(j,i,c)=abs(fluct/(medianres+epsilon));
            end
        end
    end
    info1=(sqrt(normfluct(:,:,1).^2+normfluct(:,:,2).^2)>thresh);
    utable(info1==1)=NaN;
    vtable(info1==1)=NaN;
    %find typevector...
    maskedpoints=numel(find((typevector)==0));
    amountnans=numel(find(isnan(utable)==1))-maskedpoints;
    discarded=amountnans/(size(utable,1)*size(utable,2))*100;
    disp(['Discarded: ' num2str(amountnans) ' vectors = ' num2str(discarded) ' %'])
    
    if GUI_avail==1
        delete (findobj(getappdata(0,'hgui'),'type', 'hggroup'))
        hold on;
        vecscale=str2double(get(handles.vectorscale,'string'));
        quiver ((findobj(getappdata(0,'hgui'),'type', 'axes')),xtable(isnan(utable)==0)+xroi-interrogationarea/2,ytable(isnan(utable)==0)+yroi-interrogationarea/2,utable_orig(isnan(utable)==0)*vecscale,vtable_orig(isnan(utable)==0)*vecscale,'Color', [0.15 0.7 0.15],'autoscale','off')
        quiver ((findobj(getappdata(0,'hgui'),'type', 'axes')),xtable(isnan(utable)==1)+xroi-interrogationarea/2,ytable(isnan(utable)==1)+yroi-interrogationarea/2,utable_orig(isnan(utable)==1)*vecscale,vtable_orig(isnan(utable)==1)*vecscale,'Color',[0.7 0.15 0.15], 'autoscale','off')
        drawnow
        hold off
    end
    
    %replace nans
    utable=inpaint_nans(utable,4);
    vtable=inpaint_nans(vtable,4);
    %smooth predictor
    try
        if multipass<passes-1
            utable = smoothn(utable,0.6); %stronger smoothing for first passes
            vtable = smoothn(vtable,0.6);
        else
            utable = smoothn(utable); %weaker smoothing for last pass
            vtable = smoothn(vtable);
        end
    catch
        %old matlab versions: gaussian kernel
        h=fspecial('gaussian',5,1);
        utable=imfilter(utable,h,'replicate');
        vtable=imfilter(vtable,h,'replicate');
    end
    
    if multipass==1
        interrogationarea=round(int2/2)*2;
        step=interrogationarea/2;
    end
    if multipass==2
        interrogationarea=round(int3/2)*2;
        step=interrogationarea/2;
    end
    if multipass==3
        interrogationarea=round(int4/2)*2;
        step=interrogationarea/2;
    end
    
    %bildkoordinaten neu errechnen:
    %roi=[];
    if numel(roi_inpt)>0
        xroi=roi_inpt(1);
        yroi=roi_inpt(2);
        widthroi=roi_inpt(3);
        heightroi=roi_inpt(4);
        image1_roi=double(image1(yroi:yroi+heightroi,xroi:xroi+widthroi));
        image2_roi=double(image2(yroi:yroi+heightroi,xroi:xroi+widthroi));
    else
        xroi=0;
        yroi=0;
        image1_roi=double(image1);
        image2_roi=double(image2);
    end
    %mask=[];
    if numel(mask_inpt)>0
        cellmask=mask_inpt;
        mask=zeros(size(image1_roi));
        for i=1:size(cellmask,1);
            masklayerx=cellmask{i,1};
            masklayery=cellmask{i,2};
            mask = mask + poly2mask(masklayerx-xroi,masklayery-yroi,size(image1_roi,1),size(image1_roi,2)); %kleineres eingangsbild und maske geshiftet
        end
    else
        mask=zeros(size(image1_roi));
    end
    mask(mask>1)=1;
    
    miniy=1+(ceil(interrogationarea/2));
    minix=1+(ceil(interrogationarea/2));
    maxiy=step*(floor(size(image1_roi,1)/step))-(interrogationarea-1)+(ceil(interrogationarea/2)); %statt size deltax von ROI nehmen
    maxix=step*(floor(size(image1_roi,2)/step))-(interrogationarea-1)+(ceil(interrogationarea/2));
    
    numelementsy=floor((maxiy-miniy)/step+1);
    numelementsx=floor((maxix-minix)/step+1);
    
    LAy=miniy;
    LAx=minix;
    LUy=size(image1_roi,1)-maxiy;
    LUx=size(image1_roi,2)-maxix;
    shift4centery=round((LUy-LAy)/2);
    shift4centerx=round((LUx-LAx)/2);
    if shift4centery<0 %shift4center will be negative if in the unshifted case the left border is bigger than the right border. the vectormatrix is hence not centered on the image. the matrix cannot be shifted more towards the left border because then image2_crop would have a negative index. The only way to center the matrix would be to remove a column of vectors on the right side. but then we weould have less data....
        shift4centery=0;
    end
    if shift4centerx<0 %shift4center will be negative if in the unshifted case the left border is bigger than the right border. the vectormatrix is hence not centered on the image. the matrix cannot be shifted more towards the left border because then image2_crop would have a negative index. The only way to center the matrix would be to remove a column of vectors on the right side. but then we weould have less data....
        shift4centerx=0;
    end
    miniy=miniy+shift4centery;
    minix=minix+shift4centerx;
    maxix=maxix+shift4centerx;
    maxiy=maxiy+shift4centery;
    
    image1_roi=padarray(image1_roi,[ceil(interrogationarea/2) ceil(interrogationarea/2)], min(min(image1_roi)));
    image2_roi=padarray(image2_roi,[ceil(interrogationarea/2) ceil(interrogationarea/2)], min(min(image1_roi)));
    mask=padarray(mask,[ceil(interrogationarea/2) ceil(interrogationarea/2)],0);
    if (rem(interrogationarea,2) == 0) %for the subpixel displacement measurement
        SubPixOffset=1;
    else
        SubPixOffset=0.5;
    end
    
    nrxreal=0;
    nrx=0;
    nry=0;
    xtable_old=xtable;
    ytable_old=ytable;
    xtable=zeros(numelementsy,numelementsx);
    ytable=zeros(numelementsy,numelementsx);
    typevector=ones(numelementsy,numelementsx);
    %x+y koordinaten aufschreiben
    for j = miniy:step:maxiy %vertical loop
        nry=nry+1;
        for i = minix:step:maxix % horizontal loop
            nrx=nrx+1;%used to determine the pos of the vector in resulting matrix
            if nrxreal < numelementsx
                nrxreal=nrxreal+1;
            else
                nrxreal=1;
            end
            startpoint=[i j];
            xtable(nry,nrxreal)=startpoint(1)+interrogationarea/2;
            ytable(nry,:)=startpoint(1,2)+interrogationarea/2;
        end
    end
    
    %xtable alt und neu geben koordinaten wo die vektoren herkommen.
    %d.h. u und v auf die gew�nschte gr��e bringen+interpolieren
    if GUI_avail==1
        set(handles.progress, 'string' , ['Frame progress: ' int2str(j/maxiy*100/passes+((multipass-1)*(100/passes))) '%' sprintf('\n') 'Interpolating velocity field']);drawnow;
        %set(handles.progress, 'string' , 'Interpolating velocity field');drawnow;
    else
        fprintf('.');
    end
    utable=interp2(xtable_old,ytable_old,utable,xtable,ytable,'*spline');
    vtable=interp2(xtable_old,ytable_old,vtable,xtable,ytable,'*spline');
    
    %add 1 line around image for border regions... linear extrap
    
    firstlinex=xtable(1,:);
    firstlinex_intp=interp1(1:1:size(firstlinex,2),firstlinex,0:1:size(firstlinex,2)+1,'linear','extrap');
    xtable_1=repmat(firstlinex_intp,size(xtable,1)+2,1);
    
    firstliney=ytable(:,1);
    firstliney_intp=interp1(1:1:size(firstliney,1),firstliney,0:1:size(firstliney,1)+1,'linear','extrap')';
    ytable_1=repmat(firstliney_intp,1,size(ytable,2)+2);
    
    utable_1= padarray(utable, [1,1], 'replicate');
    vtable_1= padarray(vtable, [1,1], 'replicate');
    
    nrxreal=0;
    nrx=0;
    nry=0;
    
    xtable=zeros(numelementsy,numelementsx);
    ytable=zeros(numelementsy,numelementsx);
    
    for j = miniy:step:maxiy %vertical loop
        nry=nry+1;
        if increments<6 %reduced display refreshing rate
            increments=increments+1;
        else
            increments=1;
            if GUI_avail==1 %sprintf('\n') 'pass: 1 / ' int2str(passes)
                set(handles.progress, 'string' , ['Frame progress: ' int2str(j/maxiy*100/passes+(multipass*(100/passes))) '%' sprintf('\n') 'pass: ' int2str(multipass+1) ' / ' int2str(passes)]);drawnow;
            else
                fprintf('.');
            end
        end
        
        for i = minix:step:maxix % horizontal loop
            nrx=nrx+1;%used to determine the pos of the vector in resulting matrix
            if nrxreal < numelementsx
                nrxreal=nrxreal+1;
            else
                nrxreal=1;
            end
            startpoint=[i j];
            pos=[nry,nrxreal]; %position in der x,y,u,v MATRIX
            X=xtable_1(pos(1):pos(1)+2,pos(2):pos(2)+2); %original locations of vectors in whole image
            Y=ytable_1(pos(1):pos(1)+2,pos(2):pos(2)+2);
            U=utable_1(pos(1):pos(1)+2,pos(2):pos(2)+2); %interesting portion of u
            V=vtable_1(pos(1):pos(1)+2,pos(2):pos(2)+2); % "" of v
            
            %step ist 8, f�r 32px intare, sollte es aber 16 sein, sonst gehts nicht
            XI=X(1,1):1:X(1,3)-1; %target 32x32 grid where u and v are projected on
            XI=repmat(XI,interrogationarea,1);
            %wird falsch wenn overlap ungleich 50%
            YI=(Y(1,1):1:Y(3,1)-1)';
            YI=repmat(YI,1,interrogationarea);
            
            %interpolate velocity information from 9 points to size of interrogationarea
            UI = interp2(X,Y,U,XI,YI,'*linear'); %spline has minimally lower noise
            VI = interp2(X,Y,V,XI,YI,'*linear');
            
            minY=floor(min(min(YI+VI)));
            maxY=ceil(max(max(YI+VI)));
            minX=floor(min(min(XI+UI)));
            maxX=ceil(max(max(XI+UI)));
            %wenn kleiner als 1 dann nicht oder so...
            if minY<1
                minY=1;
            end
            if minX<1
                minX=1;
            end
            if maxX>size(image2_roi,2)
                maxX=size(image2_roi,2);
            end
            if maxY>size(image2_roi,1)
                maxY=size(image2_roi,1);
            end
            %fehler wenn dispalcement am rand zu hoch, dann wird minX negativ
            try
                imageportion=image2_roi(minY:maxY,minX:maxX);
                
                gridportionX=minX:1:maxX;
                %gridportionX=repmat(gridportionX,size(gridportionX,1),1);
                
                gridportionY=minY:1:maxY;
                %gridportionY=repmat(gridportionY,size(gridportionX,1),1);
                gridportionY=gridportionY';
                
                image1_crop=image1_roi(j:j+interrogationarea-1, i:i+interrogationarea-1);
               image2_crop_i=interp2(gridportionX,gridportionY,double(imageportion),XI+UI,YI+VI,imdeform); %linear is 3x faster and looks ok...

                if mask(round(j+interrogationarea/2),round(i+interrogationarea/2))==0
                    result_conv =fftshift(real(ifft2(conj(fft2(image1_crop)).*fft2(image2_crop_i))));
                    result_conv=result_conv/max(max(result_conv))*255; %normalize, peak=always 255
                    [y,x] = find(result_conv==255);
                    if size(x,1)>1 %if there are more than 1 peaks just take the first
                        x=x(1:1);
                    end
                    if size(y,1)>1 %if there are more than 1 peaks just take the first
                        y=y(1:1);
                    end
                    if isnan(y)==0 && isnan(x)==0
                        try
                            if subpixfinder==1
                                [vector] = SUBPIXGAUSS (result_conv,interrogationarea,x,y,SubPixOffset);
                            elseif subpixfinder==2
                                [vector] = SUBPIX2DGAUSS (result_conv,interrogationarea,x,y,SubPixOffset);
                            end
                        catch
                            vector=[NaN NaN]; %if something goes wrong with cross correlation.....
                        end
                    else
                        vector=[NaN NaN]; %if something goes wrong with cross correlation.....
                    end
                else %if mask was not 0 then
                    vector=[NaN NaN];
                    typevector(nry,nrxreal)=0;
                end
            catch
                vector=[NaN NaN];
                %typevector(nry,nrxreal)=0;
                %disp('Image deformation unsuccessful.')
            end
            
            %add to the vector matrix  x, y, u, v
            xtable(nry,nrxreal)=startpoint(1)+interrogationarea/2;
            ytable(nry,:)=startpoint(1,2)+interrogationarea/2;
            utable(nry,nrxreal)=utable(nry,nrxreal)+vector(1);
            vtable(nry,nrxreal)=vtable(nry,nrxreal)+vector(2);
        end
    end
    %pass_result{multipass,1}=utable;
end

%assignin('base','pass_result',pass_result);
%__________________________________________________________________________


xtable=xtable-ceil(interrogationarea/2);
ytable=ytable-ceil(interrogationarea/2);

xtable=xtable+xroi;
ytable=ytable+yroi;


%profile viewer
%p = profile('info');
%profsave(p,'profile_results')

function [vector] = SUBPIXGAUSS (result_conv,interrogationarea,x,y,SubPixOffset)
if (x <= (size(result_conv,1)-1)) && (y <= (size(result_conv,1)-1)) && (x >= 1) && (y >= 1)
    %the following 8 lines are copyright (c) 1998, Uri Shavit, Roi Gurka, Alex Liberzon, Technion � Israel Institute of Technology
    %http://urapiv.wordpress.com
    f0 = log(result_conv(y,x));
    f1 = log(result_conv(y-1,x));
    f2 = log(result_conv(y+1,x));
    peaky = y+ (f1-f2)/(2*f1-4*f0+2*f2);
    f0 = log(result_conv(y,x));
    f1 = log(result_conv(y,x-1));
    f2 = log(result_conv(y,x+1));
    peakx = x+ (f1-f2)/(2*f1-4*f0+2*f2);
    %
    SubpixelX=peakx-(interrogationarea/2)-SubPixOffset;
    SubpixelY=peaky-(interrogationarea/2)-SubPixOffset;
    vector=[SubpixelX, SubpixelY];
else
    vector=[NaN NaN];
end

function [vector] = SUBPIX2DGAUSS (result_conv,interrogationarea,x,y,SubPixOffset)
if (x <= (size(result_conv,1)-1)) && (y <= (size(result_conv,1)-1)) && (x >= 1) && (y >= 1)
    c10=zeros(3,3);
    c01=c10;c11=c10;c20=c10;c02=c10;
    for i=-1:1
        for j=-1:1
            %following 15 lines based on
            %H. Nobach � M. Honkanen (2005)
            %Two-dimensional Gaussian regression for sub-pixel displacement
            %estimation in particle image velocimetry or particle position
            %estimation in particle tracking velocimetry
            %Experiments in Fluids (2005) 38: 511�515
            c10(j+2,i+2)=i*log(result_conv(y+j, x+i));
            c01(j+2,i+2)=j*log(result_conv(y+j, x+i));
            c11(j+2,i+2)=i*j*log(result_conv(y+j, x+i));
            c20(j+2,i+2)=(3*i^2-2)*log(result_conv(y+j, x+i));
            c02(j+2,i+2)=(3*j^2-2)*log(result_conv(y+j, x+i));
            %c00(j+2,i+2)=(5-3*i^2-3*j^2)*log(result_conv_norm(maxY+j, maxX+i));
        end
    end
    c10=(1/6)*sum(sum(c10));
    c01=(1/6)*sum(sum(c01));
    c11=(1/4)*sum(sum(c11));
    c20=(1/6)*sum(sum(c20));
    c02=(1/6)*sum(sum(c02));
    %c00=(1/9)*sum(sum(c00));
    
    deltax=(c11*c01-2*c10*c02)/(4*c20*c02-c11^2);
    deltay=(c11*c10-2*c01*c20)/(4*c20*c02-c11^2);
    peakx=x+deltax;
    peaky=y+deltay;
    
    SubpixelX=peakx-(interrogationarea/2)-SubPixOffset;
    SubpixelY=peaky-(interrogationarea/2)-SubPixOffset;
    vector=[SubpixelX, SubpixelY];
else
    vector=[NaN NaN];
end