function [count]=erode_filter(a2,width,ratio)
erode_filter=ones(1,floor(width/ratio));
a1=imclose(a2,strel('disk', 5,5));
a3=imfill(a1,'holes');
eroded_image1=imerode(a3,erode_filter);
eroded_image2=imerode(eroded_image1,strel('disk', 3,4));
eroded_image=bwareaopen(eroded_image2,40);
palm=imdilate(eroded_image,erode_filter);
finger=~palm.*a2; %figure;imshow(finger)
finger1=imopen(finger,ones(10,2));
%figure;imshow(finger1);
x3=imerode(finger1,ones(3,3));
fingers=bwareaopen(x3,500);%figure;imshow(fingers);
%figure;imshow(fingers);title('fingers');
%x3=imclearborder(fingers);figure;imshow(x3);
subplot(2,2,4);imshow(fingers);
%x2=bwconncomp(fingers,8);
%number_of_fingers=x2.NumObjects;
%%
stats = regionprops(fingers);
count=0;
for index=1:length(stats)
    if  (stats(index).BoundingBox(3)*stats(index).BoundingBox(4) > 100);
      count=count+1;
     end
end