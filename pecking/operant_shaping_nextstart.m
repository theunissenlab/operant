function operant_shaping_nextstart(obj, event)

global bird_name real_date Trial peck dio starttime lasttime fs fid_out1...
    fid_out2 fid_out3 fid_out4 fid_out5 AS YGO YNOGO TimerFeeder FeederDown_Timer...
    ProbaGo TimerStop TimerStart Test_Duration
TIME_UP = 15; %This is the time feeder is up in sec

%% Get experiment files

TI = clock;
file_name1 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%d_parameters.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)),Trial);
fid_out1 = fopen(file_name1, 'wt');
fprintf(fid_out1,'we''re running trials to examine the shaping process in zf''s.\nThe probability to get a GoStim is %d.\nWhat''s being recorded is the time stamp (since the begining of the experiment) when the bird pecks the key pad.\n', ProbaGo);
fprintf(1, 'parameters of this trial will be printed to file %s\n', file_name1);

file_name2 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%d_TimeStamp.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)),Trial);
fprintf(1, 'Time Stamps will be printed to file %s\n', file_name2);
fid_out2 = fopen(file_name2, 'wt');
if fid_out2 == -1
    fprintf(1, 'Error: could not open file name %s\n', file_name2);
    pause();
end
fprintf(fid_out2,'time(sec)\tVocalizationPlayed\n');

file_name3 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%d_KeyTrack.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), Trial);
fprintf(1, 'Results of key monitoring will be printed to file %s\n', file_name3);
fid_out3 = fopen(file_name3, 'wt');
fprintf(fid_out3, 'time(sec)\tMiddle_key_status\n');

file_name4 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%d_FeederTrack.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), Trial);
fprintf(1, 'Results of Feeder monitoring will be printed to file %s\n', file_name4);
fid_out4 = fopen(file_name4, 'wt');
fprintf(fid_out4, 'time(sec)\tFeeder_mouvement\n');
file_name5 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%d_Stims.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), Trial);
fid_out5 = fopen(file_name5, 'wt');
if fid_out5 == -1
    fprintf(1, 'Error: could not open file name %s\n', file_name5);
    pause();
end
%% Define digital IO object
dio = digitalio('mcc', 0);
hwlinein1=addline(dio,0:7,0,'out');
hwlinein2=addline(dio,0:3,1,'out');
hwlineout=addline(dio,0:2,2,'in');
set(dio,'TimerFcn',@switchreadop_choice_shaping_auto);
set(dio,'TimerPeriod',.1);  % Sets the event period to 100 ms
putvalue(dio.line(1),1);  % Don't know about this one. Guess is the main ligth
putvalue(dio.line(5),0);  % Light for the left pecking key
putvalue(dio.line(8),1);  % Light for the top pecking key
putvalue(dio.line(11),0);  % Light for the right pecking key
Past_inval = zeros(3); %set the past status of the pecking keys to 0


%% Create the timer to bring the feeder down
FeederDown_Timer = timer;
FeederDown_Timer.TimerFcn = {@feeder_down_choice, dio};
FeederDown_Timer.BusyMode = 'queue';
FeederDown_Timer.ExecutionMode = 'singleShot';
FeederDown_Timer.StartDelay = TIME_UP;

%% Create the timer to bring the feeder up
TimerFeeder = timer;
TimerFeeder.TimerFcn = {@feeder_up_choice, dio, FeederDown_Timer};
TimerFeeder.BusyMode = 'queue';
TimerFeeder.ExecutionMode = 'singleShot';
TimerFeeder.StartFcn = @(x,y)fprintf('***TimerFeeder ON!***\n');

%% Create the timer to stop the trial 30 min after the first peck
Trial = Trial + 1;
if Trial <= 3
    stop(TimerStart);
    TimerStop = timer;
TimerStop.Timerfcn = {@operant_shaping_nextstop}
    TimerStop.BusyMode = 'queue';
    TimerStop.ExecutionMode = 'fixedDelay';
    TimerStop.StartDelay = Test_Duration;

else
    stop(TimerStart);
    TimerStop = timer;
    TimerStop.Timerfcn = {@operant_shaping_finalstop};
    TimerStop.BusyMode = 'queue';
    TimerStop.ExecutionMode = 'fixedDelay';
    TimerStop.StartDelay = Test_Duration;
end

peck = zeros(1,3);

%% Load song files (already loaded at the first trial)
%[YGO,FS1] = wavread('C:\Users\Yuka\Documents\MATLAB\Shaping_Songs\Track1long.wav');
%[YNOGO,FS2] = wavread('C:\Users\Yuka\Documents\MATLAB\Shaping_Songs\Track5long.wav');
AS = audiostreamer(YGO,fs);
fprintf(fid_out5,'The GoStim used is: C:\\Users\\Yuka\\Documents\\MATLAB\\Shaping_Songs\\Track1long.wav\nThe NoGo Stim used is C:\\Users\\Yuka\\Documents\\MATLAB\\Shaping_Songs\\Track5long.wav\n');


%% These commands are needed to get the program running. 'start(dio)' gets
% switchreadop_choice_shaping_auto involved.
starttime=clock;
fprintf(fid_out1,'The protocol started at %d:%d:%d \n', starttime(4), starttime(5), fix(starttime(6)));
fprintf('************Start of Trial %d at %d:%d:%d************\n', (Trial-1), starttime(4), starttime(5), fix(starttime(6)));
lasttime=starttime;
start(dio);
end


