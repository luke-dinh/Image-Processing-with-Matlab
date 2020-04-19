I1 = imread('d:/Tâm 2.jpg');
I = I1 - 25;
M = imfilter_artistic(I);
imshow(M);
imwrite(M, 'd:/ex9.jpg', 'jpg')