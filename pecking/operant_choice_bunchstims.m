%% rough outline for operant test USES ONLY Top PECK PAD
% Compare to operant_choice that was preparing stim on the fly, this code...
% prepare a bunch of stim in advance so that when running the experiment...
% code just have to wavread file and not to compile them.

%have to make som variables global.  Which? Those shared between theload ha
%various functions
clear all
global peck dio starttime lasttime fs fid_out1 AS YGO YNOGO TimerFeeder...
    FeederDown_Timer fid_out2 Stims ProbaGo IndGoStims IndNoGoStims...
    TimerStop fid_out3 fid_out4 fid_out5 Trial Past_inval

fs = 44100;   % Assume that all files have the same sampling rate
TIME_UP = 15; %This is the time feeder is up in sec
Nstims = 400; %This is the total number of stims that will be prepared (NoGo + Go, proportion of each depends on ProbaGo)
ProbaGo = 0.2; %Probability of getting a Go stim whenthe bird is pecking
Input_dir = pwd;
Test_Duration = 60*30; %Duration of the trial in sec (should be set to 30min)
addpath(genpath(fullfile(Input_dir, 'audiostreamer')));


%% Get experiment file
bird_name = input('Birds''s name?:', 's');
if isempty(bird_name)
    fprintf(1, 'Invalid bird''s name - using test\n');
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

VocType = input('What type of vocalization are you working with (calls or songs)?:', 's');

if strcmp(VocType, 'songs')
    VocCat = 'So';
elseif strcmp(VocType, 'calls')
    VocCat = input('What category of vocalization are you working with?\nAg: aggressive calls\nDC: distance calls\nNO: NOCORT Distance Calls\nCO: CORT Distance Calls\nNe: nest calls\nTe: tet calls\nTh: thuck calls\nWh: Whines\n', 's');
else
    fprintf('start the code again and type a correct vocalization type calls or songs\n To exit code press "ctrl + C" and then supress all variables typing "clear all"\n');
end
TI = clock;
    
file_name1 = sprintf('%s_%s_%2d%2d%2d_test%s_trial%s_parameters.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), VocCat, Trial);
fprintf(1, 'Results will be printed to file %s\n', file_name1);
fid_out1 = fopen(file_name1, 'wt');
if fid_out1 == -1
    fprintf(1, 'Error: could not open file name %s\n', file_name1);
    pause();
end
fprintf(fid_out1,'we''re running trials to examine the emitter discrimination in zf''s.\n The vocalization category tested is %s\n The probability to get a GoStim is %d.\nWhat''s being recorded is the time stamp (since the begining of the experiment) when the bird pecks the key pad.\n', VocCat, ProbaGo);

file_name2 = sprintf('%s_%s_%2d%2d%2d_test%s_trial%s_TimeStamp.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), VocCat, Trial);
fid_out2 = fopen(file_name2, 'wt');
fprintf(fid_out2,'elapsed_time\ttype_of_stim\tStim_Index\n');

file_name3 = sprintf('%s_%s_%2d%2d%2d_test%s_trial%s_KeyTrack.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), VocCat, Trial);
fprintf(1, 'Results of key monitoring will be printed to file %s\n', file_name3);
fid_out3 = fopen(file_name3, 'wt');
fprintf(fid_out3, 'time(sec\tMiddle_Key_Status\n');

file_name4 = sprintf('%s_%s_%2d%2d%2d_test%s_trial%s_FeederTrack.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), VocCat, Trial);
fid_out4 = fopen(file_name4, 'wt');
if fid_out4 == -1
    fprintf(1, 'Error: could not open file name %s\n', file_name4);
    pause();
end
fprintf(1, 'Results of Feeder monitoring will be printed to file %s\n', file_name4);
fprintf(fid_out4, 'time(sec)\tFeeder_mouvement\n');

file_name5 = sprintf('%s_%s_%2d%2d%2d_test%s_trial%s_Stims.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), VocCat, Trial);
fid_out5 = fopen(file_name5, 'wt');
if fid_out5 == -1
    fprintf(1, 'Error: could not open file name %s\n', file_name5);
    pause();
end
fprintf(fid_out5,'Stim index\ttype of stim\tVoc1\tIVI1\tVoc2\tIVI2\tVoc3\tIVI3\tVoc4\tIVI4\tVoc5\tIVI5\tVoc6\n');

%% Prepare stims
% List the files we have as GoStim and NoGo stim in GOSTIMS and NOGOSTIMS
% directories. Create the directories (OUTGOSTIMS and OUTNOGOSTIMS) that
% will host the compiled stimuli.
[Stims, Stim_list]=LoadStims(pwd, Trial, VocCat);

% Compile the calls or songs to make the stimuli and save them under
% OUTGOSTIMS and OUTNOGOSTIMS directories.
NGoStims = 0;
NNoGoStims = 0;
if strcmp(VocType, 'calls')
    while NGoStims<Nstims*ProbaGo
        [YGO,FSGO,Bits,Voc,IVI]=stim_creator(Stims, Stim_list, 'GO', VocCat);
        NGoStims = NGoStims + 1;
        fprintf(fid_out5,'%d\tGoStim\t%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f\t%s\n', NGoStims, Voc{1},IVI(1),Voc{2},IVI(2),Voc{3},IVI(3),Voc{4},IVI(4),Voc{5},IVI(5),Voc{6});
        Wav_outfile = fullfile(Stims.sets(1).outdir,sprintf('GoStim_%d.wav',NGoStims));
        wavwrite(YGO,FSGO,Bits,Wav_outfile);
    end
    while NNoGoStims<Nstims*(1-ProbaGo)
        [YNOGO,FSNOGO,Bits,Voc,IVI]=stim_creator(Stims, Stim_list, 'NOGO', VocCat);
        NNoGoStims = NNoGoStims + 1;
        fprintf(fid_out5,'%d\tNoGoStim\t%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f\t%s\n', NNoGoStims, Voc{1},IVI(1),Voc{2},IVI(2),Voc{3},IVI(3),Voc{4},IVI(4),Voc{5},IVI(5),Voc{6});
        Wav_outfile = fullfile(Stims.sets(2).outdir,sprintf('NoGoStim_%d.wav',NNoGoStims));
        wavwrite(YNOGO,FSNOGO,Bits,Wav_outfile);
    end        
elseif strcmp(VocType, 'songs')
    while NGoStims<Nstims*ProbaGo
        [YGO,FSGO,Bits,Voc,IVI]=stim_creator_song(Stims, Stim_list, 'GO');
        NGoStims = NGoStims + 1;
        fprintf(fid_out5,'%d\tGoStim\t%s\t%f\t%s\t%f\t%s\n', NGoStims, Voc{1},IVI(1),Voc{2},IVI(2),Voc{3});
        Wav_outfile = fullfile(Stims.sets(1).outdir,sprintf('GoStim_%d.wav',NGoStims));
        wavwrite(YGO,FSGO,Bits,Wav_outfile);
    end
    while NNoGoStims<Nstims*(1-ProbaGo)
        [YNOGO,FSNOGO,Bits,Voc,IVI]=stim_creator_song(Stims, Stim_list, 'NOGO');
        NNoGoStims = NNoGoStims + 1;
        fprintf(fid_out5,'%d\tNoGoStim\t%s\t%f\t%s\t%f\t%s\n', NNoGoStims, Voc{1},IVI(1),Voc{2},IVI(2),Voc{3});
        Wav_outfile = fullfile(Stims.sets(2).outdir,sprintf('NoGoStim_%d.wav',NNoGoStims));
        wavwrite(YNOGO,FSNOGO,Bits,Wav_outfile);
    end
else
    fprintf('start the code again and type a correct vocalization type calls or songs');
end


%% Define digital IO object
dio = digitalio('mcc', 0);
hwlinein1=addline(dio,0:7,0,'out');%this line put the feeder on and off super fast-> doing noise
hwlinein2=addline(dio,0:3,1,'out');
hwlineout=addline(dio,0:2,2,'in');
set(dio,'TimerFcn',@switchreadop_choice_bunchstims);
set(dio,'TimerPeriod',.1);  % Sets the event period to 100 ms
putvalue(dio.line(1),1);  % Don't know about this one. Guess is the main ligth
putvalue(dio.line(5),0);  % Light for the feft pecking key
putvalue(dio.line(8),1);  % Light for the top pecking key
putvalue(dio.line(11),0);  % Light for the right pecking key
Past_inval = zeros(3); %set the past status of the pecking keys to 0


%% create the timer to bring the feeder down
FeederDown_Timer = timer;
FeederDown_Timer.TimerFcn = {@feeder_down_choice, dio};
FeederDown_Timer.BusyMode = 'queue';
FeederDown_Timer.ExecutionMode = 'singleShot';
FeederDown_Timer.StartDelay = TIME_UP;

%% create the timer to bring the feeder up
TimerFeeder = timer;
TimerFeeder.TimerFcn = {@feeder_up_choice, dio, FeederDown_Timer};
TimerFeeder.BusyMode = 'queue';
TimerFeeder.ExecutionMode = 'singleShot';
TimerFeeder.StartFcn = @(x,y)fprintf('***TimerFeeder ON!***\n');

peck = zeros(1,3);

%% create the Timer to stop the trial

TimerStop = timer;
TimerStop.Timerfcn = {@operant_shaping_finalstop};
TimerStop.BusyMode = 'queue';
TimerStop.ExecutionMode = 'fixedDelay';
TimerStop.StartDelay = Test_Duration;

%% Load the first stim files and prepare the audioplayer
IndGoStims = 1; %index for GoSTims. This index is increased each time a GoStim is played
Wav_infileGo = fullfile(Stims.sets(1).outdir,sprintf('GoStim_%d.wav',IndGoStims));
[YGO,FSGO] = wavread(Wav_infileGo);
IndNoGoStims = 1; %index for GoSTims. This index is increased each time a NoGoStim is played
Wav_infileNoGo = fullfile(Stims.sets(2).outdir,sprintf('NoGoStim_%d.wav',IndNoGoStims));
[YNOGO,FSNOGO] = wavread(Wav_infileNoGo);

AS = audiostreamer(YGO,FSGO);

%% These commands are needed to get the program running. 'start(dio)' gets
% switchreadop_choice_bunchstims involved.
starttime=clock;
fprintf(fid_out1,'The protocol started at %d:%d:%d \n', starttime(4), starttime(5), fix(starttime(6)));
fprintf('********* The protocol of trial %s started at %d:%d:%d *******\n', Trial, starttime(4), starttime(5), fix(starttime(6)));
lasttime=starttime;
start(dio);