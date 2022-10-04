function dat=read_dat(filespec,varargin)
%
%
%

if nargin<1 || isempty(filespec)
    [fstr,pstr]=uigetfile('*.dat; *.txt; *.csv','Open data file...');
    if ~fstr, return
    else
        filespec=fullfile(pstr,fstr);
    end
end

% Parse options
delimiter='\t';
commentstyle='%';
remove_space=true;
no_file_info=false;

param_list={'delimiter','commentstyle','remove_space','no_file_info'};
P=parse_options(varargin,param_list); % Parses options into option structure P

opts=fieldnames(P);
for p1=1:length(opts)
    eval(sprintf('%s=P.%s;',opts{p1},opts{p1}))
end

fid=fopen(filespec,'r');

% Read header row (variable names)
header=fgetl(fid);
var_names=strread(header,'%s','delimiter',delimiter);

if remove_space
    for i1=1:length(var_names)
        var_name=var_names{i1};
        ind_space=isspace(var_name);
        var_name(ind_space)='_';
        var_names{i1}=var_name;
    end
end

% Determine format string
pos_data=ftell(fid);
data_probe=fgetl(fid);
fseek(fid,pos_data,'bof'); % Return to initial data position

format_str=dat_read_format(data_probe,delimiter);

% Construct read format string
C_data=textscan(fid,format_str,'delimiter',delimiter,'CommentStyle',commentstyle);

fclose(fid);

% Define fields (variables)
dat=struct();

if ~no_file_info
    if ~exist('fstr','var')
        [pname,fname,ext]=fileparts(filespec);
        fstr=[fname, ext];
    end
    dat.file_info=fstr; % Store data file name as first field
end

for i1=1:length(var_names)
    dat.(var_names{i1})=C_data{i1};
end
