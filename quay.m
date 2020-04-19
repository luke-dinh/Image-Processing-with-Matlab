I1=imread('d:/209125.jpg');
imshow(I1);
[M1,N1,p]=size(I1);
scale=0.5;
M2=round(M1*scale);
N2=round(N1*scale);
I2 = zeros([M2 N2 p], class(I1));
image
for x=1:N2
for y=1:M2
I2(y,x,:) = I1(round(y/scale),round(x/scale),:);
end
end
figure
imshow(I2)
B=imrotate(I2,45);
B=insertText(B,[300,50],'Rotated');
imshow(B);
imwrite(B,'d:/anh.jpg','jpg');
