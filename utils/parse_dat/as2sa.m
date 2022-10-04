function SA=as2sa(AS,sel)
%function SA=as2sa(AS,sel)
%
% Converts structure containing arrays to a structure array with same field
% names. For examples useful for passing as a parameter structure.
%
% Array structure can hold numeric arrays and cell arrays. In case the cell
% content consists of strings the corresponding field in the structure
% array will be formatted as a string (not as a cell).

% Remove file_info (from read_dat) here if not done already
if isfield(AS,'file_info')
    AS=rmfield(AS,'file_info');
end

% The rest of the structure should exist of cell or numeric arrays of
% the same length
flds=fieldnames(AS);
nflds=length(flds);
if nflds<1
    SA=struct();
    return
end

N=length(AS.(flds{1}));
for i1=1:nflds
    if length(AS.(flds{i1}))~=N
        error('Arrays packed in array structure should be of same length.')
    end
    
    if isnumeric(AS.(flds{i1})) || islogical(AS.(flds{i1}))
        C=num2cell(AS.(flds{i1}));
    elseif iscell(AS.(flds{i1}))
        C=AS.(flds{i1});
    end
    [SA(1:N).(flds{i1})]=C{:};
end

if nargin==2
    SA=SA(sel);
end
