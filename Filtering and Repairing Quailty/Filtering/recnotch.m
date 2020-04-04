function H = recnotch(notch, mode, M, N, W, SV, SH)
%RECNOTCH Generates rectangular notch (axes) filters.
%	H = RECNOTCH(NOTCH, MODE, M, N, W, SV, SH) generates an M-by-N
%	notch filter consisting of symmetric pairs of rectangles of
%	width W placed on the vertical and horizontal axes of the
%	(centered) frequency rectangle. The vertical rectangles start at
%	+SV and -SV on the vertical axis and extend to both ends of the
%	axis. Horizontal rectangles similarly start at +SH and -SH and
%	extend to both ends of the axis. These values are with respect
%	to the origin of the axes of the centered frequency rectangle.
%	For example, specifying SV = 50 creates a rectangle of width W
%	that starts 50 pixels above the center of the vertical axis and
%	extends up to the first row of the filter. A similar rectangle
%	is created starting 50 pixels below the center and extending to
%	the last row. W must be an odd number to preserve the symmetry
%	of the filtered Fourier transform.
%
%       Valid values of NOTCH are:
%
%           'reject'    Notchreject filter.
%
%           'pass'      Notchpass filter.
%
%
%       Valid values of MODE are:
%
%           'both'          Filtering on both axes.
%
%           'horizontal'    Filtering on horizontal axis only.
%
%           'vertical'      Filtering on vertical axis only.
%
%       One of these three values must be specified in the call.
%
%   H = RECNOTCH(NOTCH, MODE, M, N) sets W = 1, and SV = SH = 1.
% 
%  H is of floating point class single. It is returned uncentered
%  for consistency with filtering function dftfilt. To view H as an
%  image or mesh plot, it should be centered using Hc = fftshift(H).

%   Copyright 2002-2009 R. C. Gonzalez, R. E. Woods, and S. L. Eddins
%   From the book Digital Image Processing Using MATLAB, 2nd ed.,
%   Gatesmark Publishing, 2009.
%
%   Book web site: http://www.imageprocessingplace.com
%   Publisher web site: http://www.gatesmark.com/DIPUM2e.htm

% Preliminaries.
if nargin == 4
   W = 1;
   SV = 1;
   SH = 1;
elseif nargin ~= 7
   error('The number of inputs must be 4 or 7.')
end
% AV and AH are rectangle amplitude values for the vertical and
% horizontal rectangles: 0 for notchreject and 1 for notchpass.
% Filters are computed initially as reject filters and then changed
% to pass if so specified in NOTCH.
if strcmp(mode, 'both')
   AV = 0;
   AH = 0;
elseif strcmp(mode, 'horizontal')
   AV = 1; % No reject filtering along vertical axis. 
   AH = 0;
elseif strcmp(mode, 'vertical')
   AV = 0;
   AH = 1; % No reject filtering along horizontal axis.
end
if iseven(W)
   error('W must be an odd number.')
end
   
% Begin filter computation. The filter is generated as a reject
% filter. At the end, it are changed to a notchpass filter if it
% is so specified in parameter NOTCH.
H = rectangleReject(M, N, W, SV, SH, AV, AH);

% Finished computing the rectangle notch filter. Format the
% output.
H = processOutput(notch, H);
    
%------------------------------------------------------------------%
function H = rectangleReject(M, N, W, SV, SH, AV, AH)
% Preliminaries.
H = ones(M, N, 'single');
% Center of frequency rectangle.
UC = floor(M/2) + 1;
VC = floor(N/2) + 1;
% Width limits.
WL = (W - 1)/2;
% Compute rectangle notches with respect to center.
% Left, horizontal rectangle.
H(UC-WL:UC+WL, 1:VC-SH) = AH;
% Right, horizontal rectangle.
H(UC-WL:UC+WL, VC+SH:N) = AH;
% Top vertical rectangle.
H(1:UC-SV, VC-WL:VC+WL) = AV;
% Bottom vertical rectangle.
H(UC+SV:M, VC-WL:VC+WL) = AV;

%------------------------------------------------------------------%
function H = processOutput(notch, H)
% Uncenter the filter to make it compatible with other filters in
% the DIPUM toolbox.
H = ifftshift(H);
% Generate a pass filter if one was specified.
if strcmp(notch, 'pass')
   H = 1 - H;
end


