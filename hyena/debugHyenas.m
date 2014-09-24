global dio AS starttime
Input_dir = pwd;
%addpath(genpath(fullfile(Input_dir, 'audiostreamer')));
dio = digitalio('mcc', 0);
hwlinein1=addline(dio,0:4,1,'in');
%hwlinein2=addline(dio,0:3,1,'out');
set(dio,'TimerFcn',@readstatusHyenas);
set(dio,'TimerPeriod',.1);
%[Y,FS] = wavread('C:\Users\Yuka\My Documents\MATLAB\shaping_Songs\WhiBlu4917_110304-DC-02.wav');
%Y=Y(1000:4969,1);
%AS = audiostreamer(Y,FS);
starttime=clock