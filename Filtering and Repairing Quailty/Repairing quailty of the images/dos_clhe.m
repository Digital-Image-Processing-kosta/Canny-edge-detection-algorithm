function J = dos_clhe(I,bit_depth,limit)
% dos_clhe  Enhance contrast using histogram equalization.
%   J = dos_clhe(I,bit_depth,limit) transforms the intensity of input image
%   I, so that the histogram of the output image J has the approximately
%   uniform distribution with 2^bith_depth bins. To avoid the contrast
%   being overemphasized, the limit argument is used to clip all values
%   higher than the limit in the histogram of the input image. The values 
%   that are clipped are evenly distributed accross the entire histogram.
%   Intesity values of image I should be in rage: [0,1].
%   bit_depth is an intiger.
%   limit is in range [0,1];
%
%   J = dos_clhe(I,bit_depth) transforms the intensity of input image
%   I, so that the histogram of the output image J has the approximately
%   uniform distribution with 2^bith_depth bins. Since the parameter limit
%   is not specified, the limit is set to 0.01
%
%   J = dos_clhe(I) transforms the intensity of input image
%   I, so that the histogram of the output image J has the approximately
%   uniform distribution with 2^bith_depth bins. Since the parameters limit
%   and bit_depth are not specified, the limit is set to 0.01 and bit_depth
%   to 8
% 
%See also histeq, adapthisteq


% --- Argument verification --- %
if (nargin < 1) || (nargin>3) 
    error('Error: Number of parameters sent to the function ''dos_clhe.m'' exceeds expected range');
elseif nargin == 2 
    limit = 1;
elseif nargin == 1
    limit = 1;
    bit_depth = 8;
end
% Checking a pixel value format of parameter I
if (~isa(I,'double')) 
    error('Error: Input argument I in ''dos_clhe.m'' function has to be a type double');
end
% Checking a if value of parameter limit exceeds demanded range
if (limit<0 || limit>1) 
    error('Error: Input argument limit in ''dos_clhe.m'' function has to be element of [0,1]');
end


L=2^bit_depth;
[N,M]=size(I);
numberOfClipped=0; % used to count the number of pixels above the limit
rk=zeros(1,L);     % quantization levels of input image (scaled)
sk=zeros(1,L);     % quantization levels of output image
Pr=zeros(1,L);     % histogram of the unput image
% scaling the quantization levels to match the levels of the output image
I=I*(L-1);
I=round(I);
I=I/(L-1);
for k=0:L-1
    rk(k+1)=k/(L-1); % rk(k+1) is quantization level
    Pr(k+1)=sum(sum(I==rk(k+1)))/N/M; % sum all the pixels with value equal to the current quantization level
    if(Pr(k+1)>limit) % if the value of the current bin of histogram is higher than the limit
        numberOfClipped=numberOfClipped+(Pr(k+1)-limit); % increase the numberOfClipped by the number that exceeds the limit
        Pr(k+1)=limit; % saturate the bin value to the value of limit
    end
end
Pr=Pr+numberOfClipped/L; % evenly distribute number of clipped pixels accross the whole histogram
for k=0:L-1
    sk(k+1)=sum(Pr(1:k+1)); 
end
J=zeros(N,M);
for i=1:N
    for j=1:M
        J(i,j)=sum(sk.*(rk==I(i,j))); % find the quantization level of I(i,j) in rk that matches quantization level in sk
    end
end
end
