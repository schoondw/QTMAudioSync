# QTMAudioSync

A toolbox for synchronizing audio files with QTM mocap files using SMPTE time code.

Developed by Erwin Schoonderwaldt

This is a trial version. Please do not distribute.

For further questions, contact Erwin Schoonderwaldt at erwin.schoonderwaldt@qualisys.se

Latest update: 2018-04-16


## Brief instructions

Add this folder with its subfolders to the Matlab path.

The script "qtm_mocap_audio_sync_using_smpte.m" in the subfolder "scripts_and_pipelines" is the main script for pairing and cropping audio files based on SMPTE time code.
The scripts can be performed at once or in steps (per cell). The results are stored in an Excel file, allowing to review the results. The steps:
1) Specify parameter structure, for example regarding the file naming and the folder structure (location of mocap and audio input and output files). The values can be edited.
2) Pairing of the audio files based on an internal time reference from the sequences (BWF standard). The results are stored in a sheet in the Excel file.
3) Pairing of mocap files with audio files based on SMPTE time code. The results are stored in a sheet in the Excel file.
4) Cropping of the audio files based on the information stored in the Excel file. The resulting audio files are named after the mocap file with the audio file name (corresponding to track in AudioDesk) as a suffix.

The QTM files need to be exported to Matlab. Please make sure that TimeCode is checked in the export settings.

The folder structure should be organized as specified in the script parameter section (or vice versa). The folders can be specified as subfolders relative to the current path (Matlab working directory).


## Recordings

Recordings in this example were made in AudioDesk, the software delivered with the MOTU sound device.

Recording of audio: multi-track recording. One of the tracks must contain the SMPTE signal sent to the mocap system (in this example the track "LTC"). The easiest way to achieve that is to loop back the SMPTE signal to one of the analog inputs on the sound device.

Audio files must be exported as BWF format, and extended wav format including a time reference.

Important: audio files must be recorded without pausing; a continuous SMPTE signal is required!

In AudioDesk recordings can be stopped to avoid very long audio tracks. Each time a recording is started a new set of audio files will be created.

Note: it is recommended to use Qualisys with external timebase using SMPTE time code or the word clock signal from the audio device for drift-free synchronization. This is done in the Synchronization settings in QTM. The sync script can also be used without the use of external timebase. However, the sync might be affected by drift then, especially for long audio recordings.


## Example

Change the Matlab working directory to the subfolder "examples".

Run the script "qtm_mocap_audio_sync_using_smpte.m" with the parameters below (first cell of the script).

```matlab
P = struct(... % General sync parameters
    'mocap_path','.',... 'QTM-mat',... % (sub)folder containing mocap files (QTM exported .mat files)
    'audio_path','Audio Files',... 'Audio',... % (sub)folder containing audio files (BWF format, .wav)
    'sync_path','.',... 'Audio Synced',... % (sub)folder to which cropped audio files are written
    'ltc_track_name','LTC',...'LTC',... % Name of audio track containing the recorded SMPTE signal (linear time code)
    ...
    'sync_admin_file','sync_admin.xlsx',... % File containing all sync information
    'audio_data_sheet','audio_data',... % Time stamp admin (decoded LTC) for audio files (auto-generated)
    'sync_admin_sheet','sync_admin',... % mocap-audio pairing and audio cropping parameters (auto-generated)
    'sync_audio_suffix','track'... % rename method: track/file; 'track' assumes AudioDesk file name convention (track name and index, e.g. MIC1-02.wav)
    );
```

The script should add the sync_admin.xlsx file with synchronization info and three audio files to the current working directory (see content of "example output" folder).

