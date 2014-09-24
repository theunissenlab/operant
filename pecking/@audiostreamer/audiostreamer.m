function as = audiostreamer(varargin)
% audiostreamer - audioplayer object with real time update ability
%
% audiostreamer inherets from the audioplayer object, so you can use an
% audiostreamer object exactly as you would an audioplayer object.
% Audiostreamrs objects have the added functionality of an 'update' method,
% allowing you to change the audio as it is being played
%
% example:
% load handel
% [b a] = butter(4,1000/Fs*2);
% as = audiostreamer(y,Fs);
% play(as);
% y = filter(b,a,y);
% pause(1)
% as = update(as,y);
%
% type 'help audioplayer' for more info
% 
% Author - Andrew Schwartz
% Version 1.0, 08/10/2010

as.initargs = varargin(2:end);          %store all args except waveform
player = audioplayer(varargin{:});      %create audioplayer
as = class(as,'audiostreamer',player);  %declare class, inheret from player