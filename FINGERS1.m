function [number_of_fingers]=FINGERS(image,ratio)
%%
%image='.jpg';
img=imread(image);
img=imresize(img,[200,200]);
%figure,imshow(img),
%RGB=double(img);

%skin detection:
YCBCR = rgb2ycbcr(img);
%[m,n,l] = size(img);
Cb=double(YCBCR(:,:,2));
Cr=double(YCBCR(:,:,3));
Cr = reshape(Cr, 1, prod(size(Cr)));
Cb = reshape(Cb, 1, prod(size(Cb)));
rmean=mean(Cr);
bmean=mean(Cb);
rbcov=cov(Cr,Cb);
z4=get_likelyhood(image,rmean,bmean,rbcov);
figure,imshow(z4)
%%
%z5=graythresh(z4);
%z6=~im2bw(z4,z5-0.05);
%figure;imshow(z6);
%z1=bwareaopen(z6,50);
%z3=imerode(z1,strel('disk',4));
%figure;imshow(z3)
%z2=imdilate(z3,strel('disk',4));
%a2=imfill(z2,'holes');
%figure;imshow(a2)
%%
[pks,loc]=findpeaks(imhist(z4));
w=find(pks==max(pks));
ints=loc(w)/255;
z1=z4-ints;
z5=(z1>0.01) ;
z3=z1 < -0.010;
z=z3+z5;
%figure;imshow(z)
%%
%z7=size(z);
%z6=zeros(z7(1),z7(2),3);
%z6(:,:,1) = z;
%z6(:,:,2) = z;
%z6(:,:,3) = z;
%final=double(z6).*double(img);
%figure,imshow(uint8(final))
%% Converting to Binary:
%a=graythresh(z);
%a3=(im2bw(z,a));
a2=imdilate(z,strel('disk',2));
%a1=imfill(a4,'holes');
%figure,imshow(a2)
%a2=imresize(a1,[200 200]);
stats=regionprops(a2);
x1=stats.Centroid;
%%
sizea2=size(a2);count=0;bound1=0;
for j=floor(x1(1)):-1:1  
    diff=abs(a2(floor(x1(2)),floor(x1(1)))-a2(floor(x1(2)),j));
    if diff >0;
        count=count+1;
    else count=0;
    end
    if count > 10
        bound1=j+10;break;
    end;
end
bound1=abs(floor(x1(1)-bound1));
% bound2
for j=floor(x1(1)):sizea2(2)
         diff=abs(a2(floor(x1(2)),floor(x1(1)))-a2(floor(x1(2)),j));
    if diff>0;
        count=count+1 ;
    else count=0;
    end
    if count > 10
        bound2=j-10;
        bound2=abs(floor(x1(1)-bound2));
        break;
    else bound2=0;
    end
end
%%
width=2*max(bound1,bound2);
erode_filter=ones(1,floor(width/ratio));
%%
eroded_image1=imerode(a2,erode_filter);
eroded_image2=imerode(eroded_image1,strel('disk', 3,4));
eroded_image=bwareaopen(eroded_image2,40);
palm=imdilate(eroded_image,erode_filter);
finger=~palm.*a2;
%%
finger1=imerode(finger,ones(10,2));
fingers=bwareaopen(finger1,50);
%figure;imshow(fingers);title('fingers');
x3=imclearborder(fingers);
x2=bwconncomp(x3,8);
number_of_fingers=x2.NumObjects;
%%
stats = regionprops(x3);
count=0;
for index=1:length(stats)
    if  (stats(index).BoundingBox(3)*stats(index).BoundingBox(4) > 40);
      count=count+1;
     end
end
