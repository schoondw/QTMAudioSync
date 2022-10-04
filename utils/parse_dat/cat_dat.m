function dat=cat_dat(varargin)
% function dat=cat_dat(varargin)
%
% Concatenates arrays corresponding to similar fields in input data
% structures. Useful in combination with read_dat to concatenate several
% tables. Structures should be 1x1, only the contents can be arrays.
% 
% Example:
% dat1=struct('a',[1 2 3]','b',[11 12 13]');
% dat2=struct('a',[4 5 6]','b',[14 15 16]');
% dat=cat_dat(dat1,dat2)
% 
% Results in dat with fields 'a' 1:6 and 'b' 11:16


% Possible alternative?
% (Source: http://stackoverflow.com/questions/5882177/matlab-structure-merge)
% data = [data1 data2 data3 data4];    %# Create a structure array of your data
% names = fieldnames(data);            %# Get the field names
% cellData = cellfun(@(f) {vertcat(data.(f))},names);  %# Collect field data into
%                                                      %#   a cell array
% data = cell2struct(cellData,names);  %# Convert the cell array into a structure



if nargin<2
    disp('Please specify at least two data structures to concatenate')
    dat=false;
    return
else
    N=nargin;
end

% Check fields
ref_flds=fieldnames(varargin{1});
n_flds=length(ref_flds);
for i1=2:N
    chk_flds=intersect(fieldnames(varargin{i1}),ref_flds);
    if length(fieldnames(varargin{i1}))~=n_flds || length(chk_flds)~=n_flds
        error('Fields of input dat structures should be the same')
    end
end

dat=varargin{1};
dat.file_info='';
for i1=2:N
    % dat_cat=varargin{i1};
    for i_fld=1:n_flds
        if ~strcmp(ref_flds{i_fld},'file_info')
            dat.(ref_flds{i_fld})=[dat.(ref_flds{i_fld}); ...
                varargin{i1}.(ref_flds{i_fld})];
        end
    end
end