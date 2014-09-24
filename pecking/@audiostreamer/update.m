function as = update(as,y,n)
% update - update the audio buffer of an audiostreamer object
%
% as = update(as,y,n)
% as is a handle to the current audiostreamer object
% y is the new audio
% n is the sample in y to start playing from. If not specified, uses the
% current sample in the current audio. Use 1 to start playing from the
% beginning of the new audio y.
%
% n can also be a [start stop] range, similar to the play() method of
% audioplayer.


%create new player object with updated audio
newPlayer = audioplayer(y,as.initargs{:});
%and set to stop current audioplayer when started
set(newPlayer,'UserData',as)
set(newPlayer,'StartFcn','stop(get(obj,''UserData''))')

%bypass audoplayer StopFcn to avoid triggering here
sfn = get(as,'StopFcn');
set(as,'StopFcn',[]);

%only play if we're already currently playing
if strcmp(get(as,'Running'),'on')
    if nargin<3,    %default: start from current
        play(newPlayer,get(as,'CurrentSample'));
    else            %start from sample
        play(newPlayer,n);
    end
end

% transfer user-settable object properties
proplist = {'UserData','Tag','TimerFcn','TimerPeriod','StartFcn'};
for pi=1:length(proplist)
    set(newPlayer,proplist{pi},get(as,proplist{pi}));
end
% and restore StopFcn that we bypassed earlier
set(newPlayer,'StopFcn',sfn);

%link as to new audioPlayer
as.audioplayer = newPlayer;