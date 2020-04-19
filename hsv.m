webcamlist;
cam = webcam(1);
preview(cam);
cam.Resolution = '1280x720';
img = snapshot(cam); 
imshow(img);
imwrite(img,'d:/snapshot.jpg','jpg');
closePreview(cam) 
clear('cam');
imshow(snapshot);
RGB = imread('d:/snapshot.jpg');
HSV = rgb2hsv(RGB);
H = HSV(:,:,1);
S = HSV(:,:,2);
V = HSV(:,:,3);
%subplot(2,2,1), 
%imshow(H)
%subplot(2,2,2), 
%imshow(S)
%subplot(2,2,3), 
%imshow(V)
%subplot(2,2,4), 
imshow(RGB)
newS = (5)*S;
newS = min(newS,1);
newV = (3)*V;
newV = min(newV,1);
newHSV = cat(3,H,newV,newS);
newRGB = hsv2rgb(newHSV);
imshow(newRGB)
figure;
imwrite(newHSV,'d:/newHSV.jpg','jpg')
new2HSV = cat(3,H,newS,newV);
%figure;
imshow(new2HSV)
imwrite(new2HSV,'d:/new2HSV.jpg','jpg')
