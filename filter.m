a = imread('Tâm.jpg');

gray = rgb2gray(a);
%h = fspecial2('motion',20,30);
a1 = imnoise(gray,'salt & pepper',0.04);
a2 = imnoise(a, 'poisson');
a3 = imnoise(a,'gaussian', 0.075);
a4 = imnoise(gray, 'gaussian', 0.01);
a5 = imnoise(gray, 'speckle', 0.1);
a6 = imnoise(a, 'speckle', 0.08);

%imwrite(b,'d:/fix4.jpg','jpg')
%imwrite(d,'d:/fix5.jpg','jpg')
%imwrite(c,'d:/fix7.jpg','jpg')
%imwrite(e,'d:/fix6.jpg','jpg')
imwrite(a1, 'd:/ex1.jpg','jpg')
imwrite(a2, 'd:/ex2.jpg','jpg')
imwrite(a3, 'd:/ex3.jpg','jpg')
imwrite(a4, 'd:/ex4.jpg','jpg')
imwrite(a5, 'd:/ex5.jpg','jpg')
imwrite(a6, 'd:/ex6.jpg','jpg')


