function [frame,subframe]=smpte2frame(SMPTE,fps)
% [frame,subframe]=smpte2frame(SMPTE,fps)
% 
% Convert SMPTE timecode to total number of SMPTE frames
% Input:
% - SMPTE: timecode structure (can be an array)
% - fps: SMPTE frame rate
%
% From QTM 2.16: Subframe obsolete

frame=zeros(size(SMPTE));
subframe=nan(size(SMPTE));
include_subframe=isfield(SMPTE,'Subframe');
for i1=1:length(SMPTE)
    frame(i1)=[SMPTE(i1).Hour*3600+SMPTE(i1).Minute*60+SMPTE(i1).Second]*fps+SMPTE(i1).Frame;
	if include_subframe
		subframe(i1)=SMPTE(i1).Subframe;
	end
end
