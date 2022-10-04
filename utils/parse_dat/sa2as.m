function AS=sa2as(SA)
%function AS=sa2as(SA)
%
% Converts structure array to a structure containing arrays with same field
% names. For examples useful for writing data with write_dat.
%
% Fields formatted as a string will be converted to cell arrays in the
% array structure.

% The rest of the structure should exist of cell or numeric arrays of
% the same length
flds=fieldnames(SA);
nflds=length(flds);
if nflds<1
    AS=struct();
    return
end

for i1=1:nflds
    if isnumeric(SA(1).(flds{i1})) || islogical(SA(1).(flds{i1}))
        AS.(flds{i1})=[SA(:).(flds{i1})]';
    else
        AS.(flds{i1})={SA(:).(flds{i1})}';
    end
end
