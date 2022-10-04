function [ts_admin]=prepare_ltc_timestamp(varargin)
%
%
%

% Main parameters
ltc_track_name='LTC';
% max_time_int=3; % Maximum time interval at beginning of file to decode
% time_stamp_admin_file='smpte_time_stamp_admin.csv';
sync_admin_file = 'admin.xlsx';
audio_data_sheet = 'audio_data';
fps_dummy=30; % Fixed value (seems only to matter for memory allocation and consistency checks in SMPTE_decoder)

% Paths (relative to current pos)
audio_path='Audio';

% Overrule main parameters
P=parse_options(varargin);
opts=fieldnames(P);
for p1=1:length(opts)
    eval(sprintf('%s=P.%s;',opts{p1},opts{p1}))
end

% List files
audio_list=dir(fullfile(audio_path,'*.wav'));
audio_files={audio_list(:).name}';

ltc_idx=strncmp(ltc_track_name,audio_files,length(ltc_track_name));
ltc_files=audio_files(ltc_idx);
track_files=audio_files(~ltc_idx);

% List of original time stamps (and fs_audio)
[C1,C2,C3]=cellfun(@(u)get_bext_timeref(audio_path,u),ltc_files,...
    'UniformOutput',false);
tref_bext_ltc=cell2mat(C1);
fs_audio=cell2mat(C2);
nSamp=cell2mat(C3);

% List of ltc time stamps (and fps_smpte)
[C4,C5]=cellfun(@(u,v,w)get_ltc_timeref(audio_path,u,v,w,fps_dummy),...
    ltc_files,C2,C3,...
    'UniformOutput',false);
tref_ltc=cell2mat(C4);
fps_smpte=cell2mat(C5);

% List of original time stamps of non-ltc track files
tref_bext_tracks=cell2mat(...
    cellfun(@(u)get_bext_timeref(audio_path,u),track_files,...
    'UniformOutput',false));

% Find matching track files for each LTC file
matchmat=repmat(tref_bext_ltc',size(tref_bext_tracks))==...
    repmat(tref_bext_tracks,size(tref_bext_ltc'));

% Perform checks
% - track file cannot be matched to more than 1 ltc file (quite unlikely to happen)
dupl_idx=sum(matchmat,2)>1;
if sum(dupl_idx)>0
    disp('Warning: track files matched to multiple LTC files.')
    disp(track_files(dupl_idx))
end

% - Identify orphan track files (could happen if recording of ltc track was
%   switched off by the user, which is quite unlikely (not to say stupid)) 
orphan_idx=sum(matchmat,2)==0;
if sum(orphan_idx)>0
    disp('Warning: orphan track files found.')
    disp(track_files(orphan_idx))
end


% Other checks (not implemented)
% - Check if SMPTE time code is continuous, i.e. without breaks
%   
%   This could happen if the user pauses the audio recording, instead of
%   stopping (i.e. pressing the recording button instead of the stop
%   button, which is a likely mistake)
%   If the SMPTE time code contains breaks, this requires a different
%   method for pairing mocap files to audio tracks, which is by default
%   based on the first time stamp of the audio file


% - Check for partial or complete overlap between LTC files
% 
%   This could happen if a user rewinds the cursor in the audio sequencer.
%   In the worst case this can lead to ambiguous association of synced
%   mocap files 
% --> to do (complementary to duplicate check above)


% Create matching file lists
nmatch=sum(matchmat,1)';
matching_tracks=cellfun(@(k)get_match_files(k,track_files,matchmat),...
	num2cell(1:length(ltc_files))','UniformOutput',false);

% Write to time stamp admin
ts_admin=struct(...
    'ltc_file',{ltc_files},...
    'n_tracks',nmatch,...
    'track_files',{matching_tracks},...
    'timeref_bext',tref_bext_ltc,...
    'timeref_ltc',tref_ltc,... 'flag_dupl',flag_dupl,...
    'fs_audio',fs_audio,...
    'N_audio',nSamp,...
    'fps_smpte',fps_smpte);

% write_dat(ts_admin,time_stamp_admin_file);

% Write to Excel (test)
ts_tab = struct2table(ts_admin);
writetable(ts_tab,sync_admin_file,'Sheet',audio_data_sheet);



%####### Subfuntions (for cellfun)
function [tr,fs,N]=get_bext_timeref(audio_path,au_file)
%
[au_info,fs]=bwfread(fullfile(audio_path,au_file),'info');
tr=au_info.bext.TimeReference;
N=au_info.nSamples;


function [tr,fps_smpte]=get_ltc_timeref(audio_path,au_file,fs_au,N_au,fps_fixed)
% 
max_time_int=3;

% Open LTC file and decode smpte
N_start=min(N_au,round(max_time_int*fs_au));
%ltc=wavread(fullfile(audio_path,au_file),N_start);
ltc=audioread(fullfile(audio_path,au_file),[1,N_start]);
try
    tc=SMPTE_decoder(ltc,fs_au,fps_fixed,0);
catch
    fprintf('\nWarning: no time code found in %s. Check timestamp admin!!!\n',au_file)
    tr=-1; fps_smpte=-1; return
end

% Extract SMPTE frame rate
fps_smpte=max(tc(:,4))+1;

% Time stamp and offset of first full frame
s1=smpte2samp(smpte_struct(tc(1,1:4)),fps_smpte,fs_au);
s_offset=round(tc(1,5)*fs_au);
tr=s1-s_offset;


function match_files=get_match_files(col,file_names,matchmat)
%
nmatch=sum(matchmat(:,col));
if nmatch>0
    fstr=repmat('%s;',1,nmatch);
    match_files=sprintf(fstr(1:end-1),file_names{matchmat(:,col)});
else
    match_files='X';
end
