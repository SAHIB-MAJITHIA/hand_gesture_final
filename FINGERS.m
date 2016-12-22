function [number_of_fingers]=FINGERS(image,ratio)
img=imread(image);
RGB=double(img);
%skin detection:
R=RGB(:,:,1);
G=RGB(:,:,2);
B=RGB(:,:,3);
%
Y=0.299*R + 0.587*G + 0.114*B;
Cb=(B-Y)*0.564 + 128;
Cr=(R-Y)*0.713 + 128;
%
s=size(RGB);
z=uint8(zeros(s(1),s(2)));
%
for i=1:s(1)
    for j=1:s(2)
        if Cb(i,j)>95 && Cb(i,j)<1450 
            z(i,j)=Cb(i,j);
        end
        if Cr(i,j)>145 &&Cr(i,j)<175
            z(i,j)=Cr(i,j);
        end
    end
end
%% Converting to Binary:
a=graythresh(z);
a3=(im2bw(z,a));a4=imdilate(a3,strel('disk',3));a1=imfill(a4,'holes');
a2=imresize(a1,[200 200]);
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
figure;imshow(fingers);title('fingers');
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