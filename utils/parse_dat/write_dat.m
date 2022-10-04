function write_dat(dat,filespec,format_str)
% function write_dat(dat,filespec,format_str)
%
% Input:
% - dat: data structure containing arrays (fieldnames = column names)
% 
% Optional:
% - filespec
% - format_str (default: format string is automatically determined from data types)

if nargin<2
    if isempty(dat.file_info)
        filterspec='*.dat';
    else
        filterspec=dat.file_info;
    end
    
    [fstr,pstr]=uiputfile(filterspec,'Save data file as...');
    if ~fstr, return
    else
        filespec=fullfile(pstr,fstr);
    end
end

% v = ver;
% if any(strcmp('Statistics Toolbox', {v.Name}))
%     % Make use of dataset export (better with regard to precision)
%     disp('Writes dat via dataset export!')
%     export(dat2dataset(dat),'File',filespec)
%     
% else

% flds=setdiff(fieldnames(dat),'file_info');
if isfield(dat,'file_info')
    dat=rmfield(dat,'file_info');
end
flds=fieldnames(dat);
N=length(dat.(flds{1}));

if nargin<3
    format_str='';
    for i1=1:length(flds)
        % disp(flds{i1})
        if isnumeric(dat.(flds{i1})) || islogical(dat.(flds{i1}))
            app='%0.12f';
            %             if sum(mod(dat.(flds{i1}),1)) % float
            %                 app='%f';
            %             else % integer
            %                 app='%d';
            %             end
        else % should be cell with strings
            app='%s';
        end
        format_str=[format_str, app, '\t'];
    end
    format_str=[format_str(1:end-2), '\n'];
end

% Open file and write header line
fid=fopen(filespec,'w');
if fid==-1
    error('write_dat: could not open file')
end
header_str=repmat('%s\t',1,length(flds));
header_str(end-1:end)='\n';
fprintf(fid,header_str,flds{:});

type=format_str(regexp(format_str,'[dfs]'));
row=cell(length(flds),1);
for i1=1:N
    % Prepare data row (cell)
    for i2=1:length(flds)
        switch type(i2)
            case 's'
                row{i2}=dat.(flds{i2}){i1};
            otherwise
                row{i2}=dat.(flds{i2})(i1);
        end
    end
    fprintf(fid,format_str,row{:});
end
fclose(fid);

% end