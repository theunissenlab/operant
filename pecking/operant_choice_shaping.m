% rough outline for operant test USES ONLY Top PECK PAD

%have to make som variables global.  Which? Those shared between theload ha
%various functions
clear all
global peck dio starttime lasttime fs fid_out1 fid_out2 fid_out3...
    fid_out4 AS YGO YNOGO TimerFeeder FeederDown_Timer ProbaGo Trial Past_inval

fs = 44100;   % Assume that all files have the same sampling rate
TIME_UP = 15; %This is the time feeder is up in sec
ProbaGo = 0.2; %Probability of getting a Go stim when the bird is pecking
Input_dir = pwd;
addpath(genpath(fullfile(Input_dir, 'audiostreamer')));

%% Get experiment files
bird_name = input('Birds''s name?:', 's');
if isempty(bird_name)
    fprintf(1, 'Invalid bird''s name - using "test"\n');
    bird_name = 'test';
end

real_date = input('Today''s date? (yymmdd):', 's');
if isempty(real_date)
    fprintf(1, 'Invalid date - file name will be created without date\n');
    real_date = '000000';
end

Trial = input('what is the trial #?', 's');
if isempty(Trial)
    fprintf(1, 'Invalid trial # - using "0"\n');
    Trial = '0';
end

PG = input('Do you want to change the probability\nto get a Go Stim by default it is 0.2?(Y/N)', 's');
if strcmp(PG,'Y')||strcmp(PG, 'y')
    PG = input('Indicate the new value (example: 0.5):', 's');
    ProbaGo = str2num(PG);
end
    

TI = clock;
file_name1 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%s_parameters.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)),Trial);
fid_out1 = fopen(file_name1, 'wt');
fprintf(fid_out1,'we''re running trials to examine the shaping process in zf''s.\nThe probability to get a GoStim is %d.\nWhat''s being recorded is the time stamp (since the begining of the experiment) when the bird pecks the key pad.\n', ProbaGo);
fprintf(1, 'parameters of this trial will be printed to file %s\n', file_name1);

file_name2 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%s_TimeStamp.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)),Trial);
fprintf(1, 'Time Stamps will be printed to file %s\n', file_name2);
fid_out2 = fopen(file_name2, 'wt');
if fid_out2 == -1
    fprintf(1, 'Error: could not open file name %s\n', file_name2);
    pause();
end
fprintf(fid_out2,'time(sec)\tVocalizationPlayed\n');

file_name3 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%s_KeyTrack.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), Trial);
fprintf(1, 'Results of key monitoring will be printed to file %s\n', file_name3);
fid_out3 = fopen(file_name3, 'wt');
fprintf(fid_out3, 'time(sec)\tMiddle_key_status\n');

file_name4 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%s_FeederTrack.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), Trial);
fprintf(1, 'Results of Feeder monitoring will be printed to file %s\n', file_name4);
fid_out4 = fopen(file_name4, 'wt');
fprintf(fid_out4, 'time(sec)\tFeeder_mouvement\n');

file_name5 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%s_Stims.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), Trial);
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
set(dio,'TimerFcn',@switchreadop_choice_shaping);
set(dio,'TimerPeriod',.1);  % Sets the event period to 100 ms
putvalue(dio.line(1),1);  % Don't know about this one. Guess is the main ligth
putvalue(dio.line(5),0);  % Light for the left pecking key
putvalue(dio.line(8),1);  % Light for the top pecking key
putvalue(dio.line(11),0);  % Light for the right pecking key
Past_inval = zeros(3,1); %set the past status of the pecking keys to 0


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

peck = zeros(1,3);

%% Load song files
[YGO,FS1] = wavread('C:\Users\Yuka\Documents\MATLAB\Shaping_Songs\Track1long.wav');
[YNOGO,FS2] = wavread('C:\Users\Yuka\Documents\MATLAB\Shaping_Songs\Track5long.wav');
AS = audiostreamer(YGO,fs);
if FS1 ~= fs
    disp('Sample frequency of GoSong is different from 44100 Hz: FIX IT!!!!!');
end
if FS2 ~= fs
    disp('Sample frequency of NoGoSong is different from 44100 Hz: FIX IT!!!!!');
end
fprintf(fid_out5,'The GoStim used is: C:\\Users\\Yuka\\Documents\\MATLAB\\Shaping_Songs\\Track1long.wav\nThe NoGo Stim used is C:\\Users\\Yuka\\Documents\\MATLAB\\Shaping_Songs\\Track5long.wav\n');


%% These commands are needed to get the program running. 'start(dio)' gets
% switchreadop_choice_shaping involved.
starttime=clock;
fprintf(fid_out1,'The trial started at %d:%d:%d \n', starttime(4), starttime(5), fix(starttime(6)));
lasttime=starttime;
start(dio);


