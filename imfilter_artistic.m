% ----------------------------------------------------------------------- %
% This function tries to simulate a generic image filter similar to the   %
% commonly-used filters of mobile applications like Instagram, Pixl-o-matic
% Photo Illusion Retro Camera, and so on.                                 %
% The image processing used here is composed by a RGB mapping and a       %
% circular/eliptical mask which desaturates, decreases brightness levels  %
% and blurs progressively the mapped image.                               %
%                                                                         %
% Input parameters:                                                       %
%   - I:	Input image. Its RGB or grayscale values must be between 0 and%
%           255 (needed for the RGB mapping).                             %
%                                                                         %
% Output variables:                                                       %
%   - M:    Filtered image.                                               %
%                                                                         %
% Example of use:                                                         %
%      I = imread('myimage.jpg');                                         %
%      M = imfilter_tony(I);                                              %
%      imshow(M);                                                         %
% ----------------------------------------------------------------------- %
%   - Author:   Víctor Martínez Cagigal                                   %
%   - Date:     06/04/2015                                                %
%   - E-mail:   victorlawliet (dot) gmail (dot) com                       %
% ----------------------------------------------------------------------- %
function I_out = imfilter_artistic(I)
    %% Pre-processing 
    I = double(I);
    % Uncoupling RGB components
    if(ndims(I)==2), R = I; G = I; B = I;               % Grayscale image
    else R = I(:,:,1); G = I(:,:,2); B = I(:,:,3); end  % RGB image
    
    %% RGB mapping
    % Polynomial LS regression (Most similar way to TONY (Pixl-o-matic))
    R_fit = [1.40115696627223e-15, -1.45653910465453e-12, 6.15795074848937e-10,...
             -1.34775549800039e-07, 1.57996083344097e-05, -0.000914721210373098,...
             0.0265470620380861, -0.129838862362938, 0.143448366057217];
    G_fit = [2.34906304960694e-08, -3.21312290637466e-05, 0.00842364967358410,...
             0.534742228237840, 1.72931394410829];
    B_fit = [1.63946764975320e-06, -0.000621980473263782, 0.885888022840955,...
             23.0618975519022];
        % However, this map can be modified by the user
        
    % Evaluating these components
    R_2 = polyval(R_fit,R);
    G_2 = polyval(G_fit,G);
    B_2 = polyval(B_fit,B);
    
    % Fixing outliers
    R_2 = 255.*(R_2>=255)+R_2.*(R_2<255 & R_2>0)+0.*(R_2<=0);
    G_2 = 255.*(G_2>=255)+G_2.*(G_2<255 & G_2>0)+0.*(G_2<=0);
    B_2 = 255.*(B_2>=255)+B_2.*(B_2<255 & B_2>0)+0.*(B_2<=0);
    
    % Mapped image
    I_map(:,:,1) = R_2; I_map(:,:,2) = G_2; I_map(:,:,3) = B_2;
    
    %% Vignette effect mask
    % Useful parameters
    r_c = floor(size(I,1)/2);       % Center coordinates
    c_c = floor(size(I,2)/2);
    L_c = sqrt(r_c^2 + c_c^2);      % Distance between center and origin
    asp = size(I,1)/size(I,2);      % Aspect relationship (elipse vignette)
    
    radii = 3; grade = 1;           % Most similar way to TONY (Pixl-o-matic)
        % However, 'radii' and 'grade' parameters can be modified by user      
    
    % Processing each pixel according to its distance to the center
        % Storage of row and columns tilings in order to avoid loops
    col = repmat(1:size(I_map,2),size(I_map,1),1);
    row = repmat((1:size(I_map,1))',1,size(I_map,2));
    % Distance between the pixel of interest and the center
    Lpc = sqrt(((r_c-row)./asp).^2 + (c_c-col).^2);
    
    % Evaluating the distance according to the weight function
    wei = radii.*((L_c-Lpc)./L_c).^grade;      
    wei = 1.*(wei>=1)+wei.*(wei<1 & wei>0)+0.*(wei<=0); % Weight of each pixel (mask)
        % Weight function with values between 0 (outer) and 1 (center)
    %% Desaturation and loss of brightness inside the weight mask
    
    % Conversion from RGB to HSV colormap
    I_hsv = rgb2hsv(I_map./255);        % Elements in range 0<=value<=1
    
    % Desaturation
    maxS = 0.5;                         % Maximum desaturation (50% loss)
    S_we = maxS+(wei./(1/(1-maxS)));    % Scaling weigths
    I_hsv(:,:,2) = S_we.*I_hsv(:,:,2);  % Desaturation
    
    % Loss of brightness
    maxV = 0.85;                        % Maximum loss of brightness (15% loss)
    V_we = maxV+(wei./(1/(1-maxV)));    % Scaling weigths
    I_hsv(:,:,3) = V_we.*I_hsv(:,:,3);  % Loss of brightness
    
    I_sv = hsv2rgb(I_hsv);              % Returning to RGB colormap

    %% Soft Blur inside the weight mask
    
    % Kernel function
    l_k = floor(size(I_sv,1)/72); 
    if(mod(l_k,2)==0), l_k = l_k+1; end % Length of the kernel used
    sig = floor(l_k/4);                   % Standard deviation 
    kernel = fspecial('gaussian',[l_k l_k],sig);
    
    % LPF Filtering with the kernel
    I_so(:,:,1) = imfilter_border(I_sv(:,:,1),[l_k l_k],'other','symmetry',kernel);
    I_so(:,:,2) = imfilter_border(I_sv(:,:,2),[l_k l_k],'other','symmetry',kernel);
    I_so(:,:,3) = imfilter_border(I_sv(:,:,3),[l_k l_k],'other','symmetry',kernel);
        % Function 'imfilter_border' is used in order to avoid the border
        % effect caused by the filtering. If you have not this function,
        % 'imfilter' can be used replacing these three lines by:
    % I_so = imfilter(I_sv,kernel);
        
    % Weighing the soft blur according to the mask
    wei = cat(3, wei, wei, wei);        % Weights for each RGB component
    I_bl = wei.*I_sv + (1-wei).*I_so;
    
    %% Output image
    I_out = I_bl;         % Elements in range 0<=value<=1
end