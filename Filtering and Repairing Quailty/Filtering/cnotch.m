function H = cnotch(type, notch, M, N, C, D0, n)
% CNOTCH Generates circularly symmetric notch filters.
% H = CNOTCH(TYPE, NOTCH, M, N, C, DO, n) generates a notch filter
% of size M-by-N. C is a K-by-2 matrix with K pairs of frequency
% domain coordinates (u, v) that define the centers of the filter
% notches (when specifying filter locations, remember that
% coordinates in MATLAB run from 1 to M and 1 to N) . Coordinates
% (u, v) are specified for one notch only. The corresponding
% symmetric notches are generated automatically. DO is the radius
% (cut-off frequency) of the notches. It can be specified as a
% scalar, in which case it is used in all K notch pairs, or it can
% be a vector of length K, containing an individual cutoff value
% for each notch pair. n is the order of the Butterworth filter if
% one is specified.
%
% Valid values of TYPE are:
%
%   'ideal'         Ideal notchpass filter. n is not used.
%
%   'btw'           Butterworth notchpass filter of order n. The default value of n is 1
%
%   'gaussian'      Gaussian notchpass filter. n is not used.
%
% Valid values of NOTCH are:
%
%   'reject' Notchreject filter.
%
%   'pass'   Notchpass filter.
%
% One of these two values must be specified for NOTCH.
%
% H is of floating point class single. It is returned uncentered
% for consistency with filtering function dftfilt. To view H as an
% image or mesh plot, it should be centered using Hc = fftshift(H).

% Preliminaries.
if nargin < 7
n = 1; % Default for Butterworth filter.
end
% Define tha largest array of odd dimensions that fits in H. This is 
% required to preserve symmetry in the filter. If necessary, a row
% and/or column is added to the filter at the end of the function.
M0 = M;
N0 = N;
if iseven(M)
    M0 = M - 1;
end
if iseven(N)
    N0 = N - 1;
end

% Center of the filter:
center = [floor(M0/2) + 1, floor(N0/2) + 1];
% Number of notch pairs.
K = size(C, 1);
% Cutoff values.
if numel(D0) == 1
    D0(1:K) = D0; % All cut offs are the same.
end

% Shift notch centers so that they are with respect to the center
% of the filter (and the frequency rectangle)
center = repmat(center, size(C,1), 1);
C = C - center;

% Begin filter computations. All filters are computed as notchreject
% filters. At the end, they are changed to notchpass filters if it
% is so specified in parameter NOTCH.
H = rejectFilter(type, M0, N0, D0, K, C, n);

% Finished. Format the output.
H = processOutput(notch, H, M, N, center);

%--------------------------------------------------------------------%
function H = rejectFilter(type, M0, N0, D0, K, C, n)
% Initialize the filter array to be an ?¡±all pass?? filter. This
% constant filter is then multiplied by the notchreject filters
% placed at the locations in C with respect to the center of the
% frequency rectangle.
H = ones(M0, N0, 'single');

% Generate filter.
for I = 1:K
    % Place a notch at each location in delta. Function hpfilter
    % returns the filters uncentered. Use fftshit to center the
    % filter at each location. The filters are made larger than
    % M-by-N to simplify indexing in function placeNotches.
    Usize = M0 + 2*abs(C(I, 1));
    Vsize = N0 + 2*abs(C(I, 2));
    filt = fftshift(hpfilter(type, Usize , Vsize, D0(I), n));
    % Insert FILT in H.
    H = placeNotches(H, filt, C(I,1), C(I,2));
end

%--------------------------------------------------------------------%
function P = placeNotches(H, filt, delu, delv)
% Places in H the notch contained in FILT.

[M N] = size(H);
U = 2*abs(delu);
V = 2*abs(delv);

% The following calculations are to determine the (common) area of
% overlap between array H and the notch filter FILT.
if delu >= 0 && delv >= 0
    filtCommon = filt(1:M, 1:N); % Displacement is in Q1.
elseif delu < 0 && delv >= 0
    filtCommon = filt(U + 1:U + M, 1:N); % Displacement is in Q2.
elseif delu < 0 && delv < 0
    filtCommon = filt(U + 1:U + M, V + 1:V + N); % Q3
elseif delu >= 0 && delv <= 0
    filtCommon = filt(1:M, V + 1:V + N); % 04
end
% Compute the product of H and filtCommon. They are registered.
P = ones(M, N).*filtCommon;
% The conjugate notch location is determined by rotating P 180
% degress. This is the same as flipping P left-right and up-down.
% The product of P and its rotated version contain FILT and its
% conjugate.
P = P.*(flipud(fliplr(P)));
P = H.*P; % A new notch and its conjugate were inserted.

%--------------------------------------------------------------------%
function Hout = processOutput(notch, H, M, N, center)
% At this point, H is an odd array in both dimensions (see comments
% at the beginning of the function). In the following, we insert a
% row if M is even, and a column if N is even. The new row and
% column have to be symmetric about their center to preserve
% symmetry in the filter. They are created by duplicating the first
% row and column of H and then making them symmetric.
centerU = center(1,1);
centerV = center(1,2);
newRow = H(1,:);
newRow(1:centerV - 1) = fliplr(newRow(centerV+1:end)); %Symmetric now.
newCol = H(:,1);
newCol(1:centerU - 1) = flipud(newCol(centerU+1:end)); %Symmetric.
% Insert the new row and/or column if appropriate.
if iseven(M) && iseven(N)
    Hout = cat(1, newRow, H);
    newCol = cat(1, H(1,1), newCol);
    Hout = cat(2, newCol, Hout);
elseif iseven(M) && isodd(N)
    Hout = cat(1, newRow, H);
elseif isodd(M) && iseven(N)
    Hout = cat(2, newCol, H);
else
    Hout = H;
end

% Uncenter the filter, as required for filtering with dftfilt.
Hout = ifftshift(Hout);

% Generate a pass filter if one was specified.
if strcmp(notch, 'pass')
    Hout = 1 - Hout;
end
