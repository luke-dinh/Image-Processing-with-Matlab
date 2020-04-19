% ----------------------------------------------------------------------- %
% 'imfilter_border' function calculates the local mean value of each pixel%
% of a given image. This function supports rectangular or gaussian windows%
% and three different ways for removing the border effect.                %
%                                                                         %
% Input parameters:                                                       %
%   - I:        Input image.                                              %
%   - wsize:    Size vector with the following structure: [weigth height] %
%   - window_t: Specifies the type of window used.                        %
%       1) 'rect'     -> Rectangular window (default).                    %
%       2) 'gaussian' -> Gaussian window.                                 %
%       3) 'circle'   -> Circle window (admits only weigth=height)        %
%       4) 'triang'   -> Triangular window.                               %
%       5) 'other'    -> Window must be specified in the 'win' parameter. %
%   - border:   Specifies the type of border processing.                  %
%       1) 'duplicate'-> Duplicates the image in each border and corner   %
%                        and calculates the local mean with that increased%
%                        image.                                           %
%       2) 'symmetry' -> (default) Builds the increased image with mirror %
%                        images. Better performance.                      %
%       3) 'value'    -> Builds the increased image keeping the border    %
%                        value in each pixel.                             %
%       4) 'none'     -> Calculates the local mean without border process-%
%                        ing.                                             %
%   - win:      Window to use. Only used if 'other' is specified in       %
%               'window_t' parameter.                                     %
%                                                                         %
% Output variables:                                                       %
%   - M:        Local mean output image.                                  %
%                                                                         %
% Example of use:                                                         %
%      I = imread('myimage.jpg');                                         %
%      M = imfilter_border(I,[11 11],'gaussian','symmetry');              %
%      imshow(M);                                                         %
% ----------------------------------------------------------------------- %
%   - Author:   Víctor Martínez Cagigal                                   %
%   - Date:     06/04/2015                                                %
%   - E-mail:   victorlawliet (dot) gmail (dot) com                       %
% ----------------------------------------------------------------------- %
function M = imfilter_border(I, wsize, window_t, border, win)
  
    % Error detection. Looking for default vales if needed
    if(nargin < 5), win = false; end
    if(nargin < 4), border = 'symmetry'; end
    if(nargin < 3), window_t = 'rect'; end
    if(nargin < 2), error('Not enough input arguments.'); end
    if(size(wsize,1) ~= 1),    error('Parameter "wsize" must be a vector [weight height].');
    elseif(size(wsize,2) ~=2), error('Parameter "wsize" must be a vector [weight height].'); end
    
    % Setting up the window according to the specified type
    switch window_t
        case 'rect'
            w = ones(wsize(1), wsize(2))./(wsize(1)*wsize(2));
        case 'gaussian'
            w = fspecial('gaussian',[wsize(1) wsize(2)],1.5);
        case 'circle'
            w = fspecial('disk', fix(max(wsize)/2));
           % wsize = [2*max(wsize),2*max(wsize)];  % Need more extra borders
        case 'triang'
            wx = window('triang',wsize(1));
            wy = window('triang',wsize(2));
            [Wx,Wy] = meshgrid(wx,wy); w = Wx.*Wy; 
            w = w./(sum(sum(w)));   % 2-D extension of an 1-D triang window
            clear('wx','wy','Wx','Wy');
        case 'other'
            if(isnumeric(win)), w = win;
            else error('Input parameter "win" is empty.'); end
        otherwise
            error('Window type is not specified.');
    end
    
    % Useful variables declaration
    rows = ceil(wsize(1)/2); cols = ceil(wsize(2)/2);    % Extra borders size
    R = size(I,1); C = size(I,2);                        % Image size
    
    % Increased image (used for cancelling the border effect)
    I_in = ones(R+2*rows,C+2*cols);
    switch border
        case 'duplicate'
            % Borders
            I_in(1+rows:R+rows,1:cols)=I(:,C-cols+1:end);   % Left
            I_in(1+rows:R+rows,C+cols+1:end)=I(:,1:cols);   % Right
            I_in(1:rows,1+cols:C+cols)=I(R-rows+1:end,:);   % Up
            I_in(R+rows+1:end,1+cols:C+cols)=I(1:rows,:);   % Down
            I_in(1+rows:R+rows,1+cols:C+cols)=I;            % Center
            % Corners
            I_in(1:rows,1:cols)=I(R-rows+1:end,C-cols+1:end); % Left-Up
            I_in(R+rows+1:end,1:cols)=I(1:rows,C-cols+1:end); % Left-Down
            I_in(1:rows,C+cols+1:end)=I(R-rows+1:end,1:cols); % Right-Up
            I_in(R+rows+1:end,C+cols+1:end)=I(1:rows,1:cols); % Right-Down
        case 'symmetry'
            % Borders
            I_h = flip(I,2);             % Mirror image (horizontal)
            I_v = flip(I,1);             % Mirror image (vertical)
            I_in(1+rows:R+rows,1:cols)=I_h(:,C-cols+1:end); % Left
            I_in(1+rows:R+rows,C+cols+1:end)=I_h(:,1:cols); % Right
            I_in(1:rows,1+cols:C+cols)=I_v(R-rows+1:end,:); % Up
            I_in(R+rows+1:end,1+cols:C+cols)=I_v(1:rows,:); % Down
            I_in(1+rows:R+rows,1+cols:C+cols)=I;            % Center
            % Corners
            I_d1 = rot90(I_v,3);         % Mirror image (diagonal m>0)
            I_d2 = rot90(I_h,3);         % Mirror image (diagonal m<0)
            I_in(1:rows,1:cols)=I_d2(C-cols+1:end,R-rows+1:end); % Left-Up
            I_in(R+rows+1:end,1:cols)=I_d1(1:cols,R-rows+1:end); % Left-Down
            I_in(1:rows,C+cols+1:end)=I_d1(C-cols+1:end,1:rows); % Right-Up
            I_in(R+rows+1:end,C+cols+1:end)=I_d2(1:cols,1:rows); % Right-Down
        case 'value'
            % Borders
            I_in(1+rows:R+rows,1:cols)=repmat(I(:,1),1,cols);        % Left
            I_in(1+rows:R+rows,C+cols+1:end)=repmat(I(:,end),1,cols);% Right
            I_in(1:rows,1+cols:C+cols)=repmat(I(1,:),rows,1);        % Up
            I_in(R+rows+1:end,1+cols:C+cols)=repmat(I(end,:),rows,1);% Down
            I_in(1+rows:R+rows,1+cols:C+cols)=I;                     % Center
            % Corners
            I_in(1:rows,1:cols)=repmat(I(1,1),rows,cols);                % Left-Up
            I_in(R+rows+1:end,1:cols)=repmat(I(end,1),rows,cols);        % Left-Down
            I_in(1:rows,C+cols+1:end)=repmat(I(1,end),rows,cols);        % Right-Up
            I_in(R+rows+1:end,C+cols+1:end)=repmat(I(end,end),rows,cols);% Right-Down
        case 'none'
            I_in = I;
            M = filter2(w,I_in);
            return;
        otherwise
            error('Window type is not specified.');
    end
    
    % Local mean calculation
    M = filter2(w,I_in);
    
    % Cutting back the original image size
    M = M(1+rows:R+rows,1+cols:C+cols);
end