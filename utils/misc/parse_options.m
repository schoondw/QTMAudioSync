function P=parse_options(C,param_list)
% function P=parse_options(C,param_list)
%
% Function for parsing parameters (options). Especially useful for functions
% with many parameters defined by default values. 
% 
% Input:
% - C: a parameter cell, containing either a parameter structure P or
%      property-value pairs (or both). In a typical implementation (see
%      example below) C represents varargin. (C can also be a structure, in
%      that case parse_options just returns it, unless it fails the
%      parm_list check.)
% - param_list: cell containing list of allowed parameters. Only properties
%               that are specified in the param_list will be accepted by
%               parse_options, otherwise an error will be thrown.
%
% Output:
% - P: a parameter structure with fields corresponding to individual parameters
%
% N.B.1 No check is done on the values, this function parses any type of data.
% N.B.2 Loose implementation (without param_list) can be especially useful
%       for nested function calls, when parameters are passed on via a
%       single parameter structure P.
%
% --------------------------------------------------------
% Example of a possible implementation in a function (foo)
% --------------------------------------------------------
% 
% function y=foo(x,varargin)
% % Parameters (defaults)
% aap=1;
% noot='lekker';
% mies={'leeftijd', 7}; % You can also use cells or structures as parameters
% 
% param_list={'aap','noot','mies'}; % For strict implementation (optional)
% P=parse_options(varargin,param_list); % Parses options into option structure P
%
% % Overrule defaults
% % - Alternative 1: hard-coding
% if isfield(P,'aap'), aap=P.aap; end
% % etc...
% 
% % - Alternative 2: automatic
% opts=fieldnames(P);
% for p1=1:length(opts)
%     eval(sprintf('%s=P.%s;',opts{p1},opts{p1}))
% end
% 
% % Body of foo
% ...
%
% N.B.3 If you want to avoid the eval statement, you can alternatively
%       define a default parameter structure inside the function, and overrule
%       the values using dynamic fieldnames.
% 
% --------------------------------------------
% Example of alternative function calls of foo
% --------------------------------------------
% Define parameters via a structure:
% >> P=struct('aap',2,'noot','vies');
% >> y=foo(x,P);
% 
% Define parameters via property-value pairs
% >> y=foo(x,'aap',2,'noot','vies');
% 
% Or even a combination of both (only one parameter structure allowed
% as first optional argument)
% >> y=foo(x,P,'mies',{'any data'});


% Parameter parsing
errmsg='Inexpected options format.';
if length(C)==1
    if isstruct(C)
        P=C;
    else
        P=C{1};
        if ~isstruct(P)
            error(errmsg)
        end
    end
elseif length(C)>1
    if mod(length(C),2)
        if ~isstruct(C{1})
            error(errmsg)
        else
            P=C{1};
            C=C(2:end);
        end
    end
    Nopts=length(C)/2;
    for i1=1:Nopts
        Prop=C{i1*2-1};
        if ~ischar(Prop)
            error([errmsg, ' Property should be a string.'])
        end
        P.(Prop)=C{i1*2};
    end
else
    P=struct();
end

if nargin==2
    options=fieldnames(P);
    nonopts=setdiff(options,param_list);
    if ~isempty(nonopts)
        nn=length(nonopts);
        errmsg=['parse_options: unknown properties' ...
            repmat('\n- %s',1,nn)];
        error(errmsg,nonopts{:});
    end
end
