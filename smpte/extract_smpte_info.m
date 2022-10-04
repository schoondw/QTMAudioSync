function [smpte_info,smpte_chk]=extract_smpte_info(SMPTE)
%
%

nSampTot=length(SMPTE);
if nSampTot<25 || diff(smpte2sec(SMPTE([1 end]))) < 1
    error('Continuous time code interval of at least 1 second required to extract the needed information.')
end

nMissingTimeStamps=sum([SMPTE.Missing]);
fps=max([SMPTE.Frame])+1;

% Crop to full frames for more sophisticated estimations
% ff=find(sign(diff([SMPTE.Subframe])')==-1)+1; % frame flips (in samples)
%ff=find(diff(int64([SMPTE.Frame]))')+1; % Start of full SMPTE frames (in mocap samples) % EST 180306 do not know why int64
ff=find(diff([SMPTE.Frame])')+1; % Start of full SMPTE frames (in mocap samples)
% if SMPTE(1).Subframe==0, ff=[1; ff]; end % include first full frame if applicable
ff_int=[ff(1) ff(end)-1]; % Full frames within first to last detected frame flip

fr=smpte2frame(SMPTE(ff_int),fps);
% nFrames=diff(fr);
% deltaSamp=diff(sfr);
% fs_est=(diff(ff_int)-deltaSamp)/nFrames*fps;
% nsf=fs_est/fps; 

nFrames=diff(fr)+1; % +1 correction needed as the first frame is starting at zero and the last frame is filled
nSamp=diff(ff_int)+1;

% Estimation of number of subframes per frame (only valid if fs is integer multiple of fps)
nsf=median(diff(ff)); % Data-based determination of number of smpte subframes (only valid in case of integer number of subframes per frame)

% Mismatch (total) of number of samples
nSamp_mismatch=nSamp-nFrames*nsf;

% Find frames where number of subframes deviates
iff_dev=diff(ff)~=nsf;
nDeviations=sum(iff_dev);

% Sample rate estimated from SMPTE (uncorrected and corrected)
% fs_est=nSamp/nFrames*fps; % uncorrected
fs_est_corr=(nSamp-nSamp_mismatch)/nFrames*fps; % corrected

smpte_info=struct(...
    'FrameStart',ff,... % index to samples, where a new frame starts (ff(1:end-1) for full frames only)
    'fps',fps,... % SMPTE frame rate
    'nSubframes',nsf,...
    'fs',fs_est_corr); % Corrected sample rate

smpte_chk=struct(...
    'Flag',logical(nDeviations) | logical(nMissingTimeStamps),...
    'nMissingTimeStamps',nMissingTimeStamps,...
    'nDeviatingFrames',nDeviations,...
    'DeviatingFrameIndex',iff_dev,... % index to FrameStart
    'TotalSampDelta',nSamp_mismatch);

% Produce a SMPTE check plot if no output arguments are requested.
if nargout==0
    figure
    % plot([[SMPTE.Subframe]' [SMPTE.Frame]' [SMPTE.Second]' [SMPTE.Minute]' [SMPTE.Hour]'])
    plot([[SMPTE.Frame]' [SMPTE.Second]' [SMPTE.Minute]' [SMPTE.Hour]'])
    hold
    hx=plot(ff(iff_dev),zeros(sum(iff_dev),1),'rx');
    set(hx,'MarkerSize',12,'LineWidth',2)
end
