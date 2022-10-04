function SMPTE=smpte_struct(varargin)
% function SMPTE=smpte_struct(Hour,Minute,Second,Frame,Subframe)
%
% QTM 2.16 and higher: Subframe obsolete
%

% Organize input
if nargin==1
    tc=varargin{1};
    if length(tc)<4 || length(tc)>5
        error('Invalid input.')
    end
elseif nargin==4 || nargin==5
    tc=[varargin{:}];
else
    error('Invalid input.')
end

% Parse tc
if length(tc)>=4
    Hour=tc(1);
    Minute=tc(2);
    Second=tc(3);
    Frame=tc(4);
    if length(tc)==5 && mod(tc(5),1)==0
        Subframe=tc(5);
    else
        Subframe=0;
    end
end

SMPTE=struct(...
    'Hour',Hour,...
    'Minute',Minute,...
    'Second',Second,...
    'Frame',Frame,...
    'Subframe',Subframe);
