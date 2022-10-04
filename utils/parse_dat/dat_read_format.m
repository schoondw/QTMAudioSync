function format_str=dat_read_format(data_probe,delimiter)
% function format_str=dat_read_format
%

% Developer notes:
% - Any empty data field in data probe is considered as being a string
%   right now (ES, 07/2010)

if nargin<2, delimiter='\t'; end

% data_elements=strread(data_probe,'%s','delimiter',delimiter);
data_elements=regexp(data_probe,delimiter,'split');
Ncols=length(data_elements);
istr=false(Ncols,1);
for i1=1:Ncols
%     [junk,ok]=str2num(data_elements{i1});
%     if ~ok || ...
%             ~isempty(strfind(data_elements{i1},':')) || ...
%             ~isempty(strfind(data_elements{i1},';')) || ...
%             ~isempty(strfind(data_elements{i1},','))
    if isnan(str2double(data_elements{i1})) && ~strcmpi(data_elements{i1},'nan')
        istr(i1)=true;
    end
end

format_cell=cell(Ncols,1);
format_cell(:)={'%f'}; % Default %f
format_cell(istr)={'%s'}; % Replace string variables

% Convert to format string
format_str=char(format_cell)';
format_str=format_str(:)';

