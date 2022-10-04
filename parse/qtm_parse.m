function MC=qtm_parse(varargin)
% function MC=qtm_parse(varargin)
%
% Parses qtm structure into an MC structure with one field per marker.
% MC will also contain a substructure with 6DOF data in case rigid bodies
% are present in the qtm file.

% Default/initial parameters
trial_name='';
sel_int=[];

% Parse input
if nargin>0 && ischar(varargin{1}) && ~isempty(dir(varargin{1}))
    filespec = varargin{1};
    varargin(1)=[];
else
    [fstr,pstr]=uigetfile('*.mat','Open trial (QTM export format)');
    if fstr
        filespec=fullfile(pstr,fstr);
    else
        return
    end
end

P=parse_options(varargin);
opts=fieldnames(P);
for p1=1:length(opts)
    eval(sprintf('%s=P.%s;',opts{p1},opts{p1}))
end

qtm=qtmread(filespec);
if isempty(trial_name)
    [junk,trial_name]=fileparts(filespec);
end

if isempty(sel_int)
    sel=1:qtm.Frames;
else
    sel=max(1,sel_int(1)):min(qtm.Frames,sel_int(2));
end

% Initiate MC structure
MC=struct(...
    'trial_name',trial_name,...
    'nframes',qtm.Frames,...
    'fs',qtm.FrameRate,...
    'time',(0:qtm.Frames-1)'/qtm.FrameRate);

% --- Parse trajectories
if isfield(qtm, 'Trajectories') % Assume that trajectories are labeled
    for i1=1:qtm.Trajectories.Labeled.Count
        MC.markers.(qtm.Trajectories.Labeled.Labels{i1})=...
            permute(qtm.Trajectories.Labeled.Data(i1,1:3,sel),[3 2 1]);
    end
end


% --- Parse rigid bodies
if isfield(qtm, 'RigidBodies')
    MC.rigid_bodies=struct();
    for i1=1:qtm.RigidBodies.Bodies
        MC.rigid_bodies.(qtm.RigidBodies.Name{i1})=struct(...
            'pos',permute(qtm.RigidBodies.Positions(i1,:,sel),[3 2 1]),...
            'rot',permute(qtm.RigidBodies.Rotations(i1,:,sel),[3 2 1]),...
            'res',qtm.RigidBodies.Residual(i1,:)',...
            'coord','Global'); % coord is a dummy variable at the moment
    end
end
