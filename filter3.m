I1 = imread('d:/T�m 2.jpg');
I = I1 - 25;
M = imfilter_artistic(I);
imshow(M);
imwrite(M, 'd:/ex9.jpg', 'jpg')