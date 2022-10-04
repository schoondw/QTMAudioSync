% qtm_mocap_audio_sync_using_smpte

% - Find matching audio files to all mocap files in the specified directory (mocap_path)
% - Path structure (relative to current path) defined in P
% - Admin files (.csv/.txt format) are written to the current path (working dir)

%% Main control parameters
% - EDIT to reflect your directory structure and file names
% - Path names relative to current working directory, or absolute path
%   names (use '.' to refer to current dir)

P=struct(... % General sync parameters
    'mocap_path','.',... 'QTM-mat',... % (sub)folder containing mocap files (QTM exported .mat files)
    'audio_path','Audio Files',... 'Audio',... % (sub)folder containing audio files (BWF format, .wav)
    'sync_path','.',... 'Audio Synced',... % (sub)folder to which cropped audio files are written
    'ltc_track_name','LTC',...'LTC',... % Name of audio track containing the recorded SMPTE signal (linear time code)
    ...
    'time_stamp_admin_file','audio_time_stamp_admin.txt',... % Time stamp admin (decoded LTC) for audio files (auto-generated)
    'sync_admin_file','sync_admin.txt',... % mocap-audio pairing and audio cropping parameters (auto-generated)
    'sync_audio_suffix','track'... % rename method: track/file; 'track' assumes AudioDesk file name convention (track name and index, e.g. MIC1-02.wav)
    );

%% Create audio time stamp admin
% Parallel audio track files are paired with corresponding LTC files, based
% on BEXT time stamp (bwf audio format). In addition a time stamp is
% extracted from the LTC track (SMPTE) 
% - Audio files must be of BWF format with correct time reference

prepare_ltc_timestamp(P);

% --> Generates the time stamp admin file for the audio files

%% Pair together mocap and audio files
% - Mocap files should be .mat files exported by QTM, including SMPTE time
%   stamp information

sync_generate_admin(P); % No predefined trial list

% --> Creates sync admin and smpte report files (as defined above)

%% Crop audio files
% - Based on sync_admin file
% - Files will be stored under sync_path
% - Audio files are renamed as corresponding mocap file, with the audio
%   track name added as a suffix.

crop_audio_files(P);

