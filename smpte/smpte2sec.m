function t=smpte2sec(SMPTE,fps,fs)
% function t=smpte2sec(SMPTE,fps,fs)
%
% Calculates in which second cummulative the time code falls
% 
% The time resolution depends on the input arguments
% - samples (in s) when fps and fs are provided (obsolete for QTM 2.16 and higher)
% - rounded to frames when only fps is provided
% - rounded to seconds when fps and fs are not given
% 

narginchk(1,3);
flag='samples';
if ~isfield(SMPTE,'Subframe'), flag='frames'; end % For QTM 2.16 and higher Subframe is no longer exported
if nargin<3, flag='frames'; end
if nargin<2, flag='seconds'; end

t=zeros(size(SMPTE));
for i1=1:length(SMPTE)
    t(i1)=SMPTE(i1).Hour*3600 + SMPTE(i1).Minute*60 + SMPTE(i1).Second; % time rounded to seconds
    if strcmp(flag,'frames')
        t(i1)=t(i1) + SMPTE(i1).Frame/fps; % time at frame level
    elseif strcmp(flag,'samples')
        t(i1)=t(i1) + SMPTE(i1).Frame/fps + SMPTE(i1).Subframe/fs; % time at sample (subframe) level
    end
end
