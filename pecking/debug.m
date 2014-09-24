global dio AS starttime
Input_dir = pwd;
addpath(genpath(fullfile(Input_dir, 'audiostreamer')));
dio = digitalio('mcc', 0);
hwlinein1=addline(dio,0:7,0,'out');
hwlinein2=addline(dio,0:3,1,'out');
hwlineout=addline(dio,0:2,2,'in');
set(dio,'TimerFcn',@readstatus);
set(dio,'TimerPeriod',.1);
putvalue(dio.line(1),0);  % Don't know about this one. Guess is the main ligth
putvalue(dio.line(5),0);  % Light for the feft pecking key
putvalue(dio.line(8),1);  % Light for the top pecking key
putvalue(dio.line(11),0);
[Y,FS] = wavread('C:\Users\Yuka\My Documents\MATLAB\shaping_Songs\WhiBlu4917_110304-DC-02.wav');
Y=Y(1000:4969,1);
AS = audiostreamer(Y,FS);
starttime=clock