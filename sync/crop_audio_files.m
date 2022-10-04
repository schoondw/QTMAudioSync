function crop_audio_files(varargin)
% Function for cropping audio files to mocap trials
% 
% The cropped files are put in a separate subfolder (default: Sync)

%% Script parameters
sync_admin_file='sync_admin.csv';

mocap_path='QTM';
audio_path='Audio';
sync_path='Sync';

sync_audio_suffix='track'; % track/file; the first assumes AudioDesk file name convention
 
%% Overrule main parameters
P=parse_options(varargin);
opts=fieldnames(P);
for p1=1:length(opts)
    eval(sprintf('%s=P.%s;',opts{p1},opts{p1}))
end

%% Process files
if ~isdir(sync_path)
    mkdir(sync_path);
end

admin=read_dat(sync_admin_file);

for i1=1:length(admin.mc_file)
    if isfield(admin,'skip') && admin.skip(i1)==1
        continue
    end
    
    [~,trial_name]=fileparts(admin.mc_file{i1});
    mc_fn=fullfile(mocap_path,admin.mc_file{i1}); % Mocap file name
    
    fprintf('Syncing %s\n',mc_fn)
    
    % Audio track names
    au_files=strread(admin.au_files{i1},'%s','delimiter',';');
    nAudioFiles=length(au_files); % Number of tracks
    
    % Create new names for synced audio file using the trial name
    au_files_sync=cellfun(@(s)rename_audio_sync(s,trial_name,sync_audio_suffix),...
        au_files,'UniformOutput',false);
    
    % Crop audio files
    for i2=1:nAudioFiles
        % read selection
        % [wav,fs,nbits]=wavread(fullfile(audio_path,au_files{i2}),eval(admin.au_crop{i1}));
        [wav,fs]=audioread(fullfile(audio_path,au_files{i2}),eval(admin.au_crop{i1}));
        au_info=audioinfo(fullfile(audio_path,au_files{i2}));
                
        % write WAV file to sync dir
        au_file_sync=fullfile(sync_path,au_files_sync{i2});
        % wavwrite(wav,fs,nbits,au_file_sync);
        audiowrite(au_file_sync,wav,fs,'BitsPerSample',au_info.BitsPerSample);
    end
    
end
disp('Done!')



% --- Helper functions
function sync_name=rename_audio_sync(au_file,trial_name,suffix_mode)
[~,suffix]=fileparts(au_file);

% Remove track index (AudioDesk naming convention)
if strcmp(suffix_mode,'track')
    k=strfind(suffix,'-');
    if ~isempty(k)
        k=k(end);
        track_idx=str2double(suffix(k+1:end));
        if ~isnan(track_idx)
            suffix=suffix(1:k-1);
        end
    end
end

sync_name=sprintf('%s_%s.wav',trial_name,suffix);

