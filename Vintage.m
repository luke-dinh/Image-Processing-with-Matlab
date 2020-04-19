im = double(imread('ex6.jpg'));
%img = imnoise(im, 'speckle', 0.1);
M = [0.393 0.769 0.189; 0.349 0.686 0.168; 0.272 0.534 0.131];
out = uint8(reshape((M*reshape(permute(im, [3 1 2]), 3, [])).', ...
           [size(im,1) size(im,2), 3]));
imwrite(out, 'd:/ex7.jpg','jpg')