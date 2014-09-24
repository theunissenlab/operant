%% rough outline for operant test USES ONLY Top PECK PAD
% Compare to operant_choice that was preparing stim on the fly and...
% operant_choice_bunchstims that was working wit only one type of call, this code...
% prepare a bunch of stim in advance for al the vocalizations categories.

%have to make som variables global.  Which? Those shared between the
%various functions
clear all
global peck dio starttime lasttime fs fid_out1 fid_out2 fid_out3 fid_out4...
    fid_out5 AS YGO YNOGO TimerFeeder FeederDown_Timer Stims ProbaGo...
    IndGoStims IndNoGoStims GO_List NOGO_List Trial bird_name real_date...
    TimerStop TimerStart Test_Duration Past_inval TodayVoc VocType

fs = 44100;   % Assume that all files have the same sampling rate
TIME_UP = 15; %This is the time feeder is up in sec
Nstims = 400; %This is the total number of stims that will be prepared (NoGo + Go, proportion of each depends on ProbaGo)
ProbaGo = 0.2; %Probability of getting a Go stim when the bird is pecking
Test_Duration = 60*30; %Duration of the trial in sec (should be set to 30min)
Testnextstart_Duration = 60*90 + Test_Duration;%Duration of the trial + the resting period in sec
Input_dir = pwd;
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

% Indicate what type of vocalizations we are working with
TodayVoc = [1 1 1 1 1 1 1 1 1 1];
TestedCall = input('What type of vocalization is the Go Stim? \nSong: 1\nBegging Calls: 2\nDistance calls: 3\nTet calls: 4\nNest Calls: 5\nWhines: 6\nThuck calls: 7\nAggressive Calls: 8\nDistress Calls: 9\nLong Tonal Calls: 10\n');
TodayVoc(TestedCall) = 0;
VocTypeList = {'So' 'Be' 'DC' 'Te' 'Ne' 'Wh' 'Th' 'Ag' 'Di' 'LT'};
VocType = VocTypeList{TestedCall};
Trial = 1;

TI = clock;
    
file_name1 = sprintf('%s_%s_%2d%2d%2d_testVC%s_trial%d_parameters.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), VocType, Trial);
fprintf(1, 'Results will be printed to file %s\n', file_name1);
fid_out1 = fopen(file_name1, 'wt');
if fid_out1 == -1
    fprintf(1, 'Error: could not open file name %s\n', file_name);
    pause();
end

file_name2 = sprintf('%s_%s_%2d%2d%2d_testVC%s_trial%d_TimeStamp.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), VocType, Trial);
fid_out2 = fopen(file_name2, 'wt');
fprintf(fid_out2,'elapsed_time\ttype_of_stim\tStim_Index\n');

file_name3 = sprintf('%s_%s_%2d%2d%2d_testVC%s_trial%d_KeyTrack.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), VocType, Trial);
fprintf(1, 'Results of key monitoring will be printed to file %s\n', file_name3);
fid_out3 = fopen(file_name3, 'wt');
fprintf(fid_out3, 'time(sec\tMiddle_Key_Status\n');

file_name4 = sprintf('%s_%s_%2d%2d%2d_testVC%s_trial%d_FeederTrack.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), VocType, Trial);
fid_out4 = fopen(file_name4, 'wt');
if fid_out4 == -1
    fprintf(1, 'Error: could not open file name %s\n', file_name4);
    pause();
end
fprintf(1, 'Results of Feeder monitoring will be printed to file %s\n', file_name4);
fprintf(fid_out4, 'time(sec)\tFeeder_mouvement\n');

file_name5 = sprintf('%s_%s_%2d%2d%2d_testVC%s_trial%d_Stims.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), VocType, Trial);
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
[Stims, Stim_list]=LoadStims_VocCat(pwd, Trial, TodayVoc);%%faire tourner pour voir si ça marche

% Compile the calls or songs to make the stimuli and save them under
% OUTGOSTIMS and OUTNOGOSTIMS directories.
NGoStims = 0;
NNoGoStims = 0;
for ss = (3:10)
    if ~TodayVoc(ss)==1
        Set = Stims.sets(ss);
        N_Stim = 0;
        while N_Stim<Nstims*ProbaGo
            [YGO,FSGO,Bits,Voc,IVI]=stim_creator_repertoire(Set, Stim_list);
            NGoStims = NGoStims + 1;
            N_Stim = N_Stim + 1;
            fprintf(fid_out5,'%d\tGoStim\t%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f\t%s\n', NGoStims, Voc{1},IVI(1),Voc{2},IVI(2),Voc{3},IVI(3),Voc{4},IVI(4),Voc{5},IVI(5),Voc{6});
            Wav_outfile = fullfile(Set.outdir,sprintf('GoStim_%d_%s.wav',NGoStims,Set.name));
            wavwrite(YGO,FSGO,Bits,Wav_outfile);
        end
    end
end
for ss = (13:20)
    if TodayVoc(ss-10)==1
        Set = Stims.sets(ss);
        N_Stim = 0;
        while N_Stim<Nstims*(1-ProbaGo)/(length(TodayVoc)-1)
            [YNOGO,FSNOGO,Bits,Voc,IVI]=stim_creator_repertoire(Set, Stim_list);
            NNoGoStims = NNoGoStims + 1;
            N_Stim = N_Stim + 1;
            fprintf(fid_out5,'%d\tNoGoStim\t%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f\t%s\n', NNoGoStims, Voc{1},IVI(1),Voc{2},IVI(2),Voc{3},IVI(3),Voc{4},IVI(4),Voc{5},IVI(5),Voc{6});
            Wav_outfile = fullfile(Set.outdir,sprintf('NoGoStim_%d_%s.wav',NNoGoStims,Set.name));
            wavwrite(YNOGO,FSNOGO,Bits,Wav_outfile);
        end 
    end
end
for ss = (1:2)
    if ~TodayVoc(ss)==1
        Set = Stims.sets(ss);
        N_Stim = 0;
        while N_Stim<Nstims*ProbaGo
            [YGO,FSGO,Bits,Voc,IVI]=stim_creator_song_repertoire(Set, Stim_list);
            NGoStims = NGoStims + 1;
            N_Stim = N_Stim + 1;
            fprintf(fid_out5,'%d\tGoStim\t%s\t%f\t%s\t%f\t%s\n', NGoStims, Voc{1},IVI(1),Voc{2},IVI(2),Voc{3});
            Wav_outfile = fullfile(Set.outdir,sprintf('GoStim_%d_%s.wav',NGoStims, Set.name));
            wavwrite(YGO,FSGO,Bits,Wav_outfile);
        end
    end
end
for ss = (19:20)
    if TodayVoc(ss-10)==1
        Set = Stims.sets(ss);
        N_Stim = 0;
        while N_Stim<Nstims*(1-ProbaGo)/(length(TodayVoc)-1)
            [YNOGO,FSNOGO,Bits,Voc,IVI]=stim_creator_song_repertoire(Set, Stim_list);
            NNoGoStims = NNoGoStims + 1;
            N_Stim = N_Stim + 1;
            fprintf(fid_out5,'%d\tNoGoStim\t%s\t%f\t%s\t%f\t%s\n', NNoGoStims, Voc{1},IVI(1),Voc{2},IVI(2),Voc{3});
            Wav_outfile = fullfile(Set.outdir,sprintf('NoGoStim_%d_%s.wav',NNoGoStims, Set.name));
            wavwrite(YNOGO,FSNOGO,Bits,Wav_outfile);
        end
    end
end

% Create 2 random list of indices to read wav files:
GO_List = randperm(NGoStims);
NOGO_List = randperm(NNoGoStims);

%% Define digital IO object
dio = digitalio('mcc', 0);
hwlinein1=addline(dio,0:7,0,'out');
hwlinein2=addline(dio,0:3,1,'out');
hwlineout=addline(dio,0:2,2,'in');
set(dio,'TimerFcn',@switchreadop_choice_bunchstimsVocCat_auto);
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

%% Load the first stim files and prepare the audioplayer
IndGoStims = 1; %index for GoSTims. This index is increased each time a GoStim is played
SETS=find(~TodayVoc);
Wav_infileGo = dir(fullfile(Stims.sets(SETS(1)).outdir,sprintf('GoStim_%d_*.wav',GO_List(IndGoStims))));
Wav_infileGo = fullfile(Stims.sets(SETS(1)).outdir,Wav_infileGo.name);
[YGO,FSGO] = wavread(Wav_infileGo);
IndNoGoStims = 1; %index for GoSTims. This index is increased each time a NoGoStim is played
SETS=find(TodayVoc);
Wav_infileNoGo = dir(fullfile(Stims.sets(SETS(1)+10).outdir,sprintf('NoGoStim_%d_*.wav',NOGO_List(IndNoGoStims))));
Wav_infileNoGo = fullfile(Stims.sets(SETS(1)+10).outdir,Wav_infileNoGo.name);
[YNOGO,FSNOGO] = wavread(Wav_infileNoGo);

AS = audiostreamer(YGO,FSGO);

%% Create the timer to stop the trial 30 min after the first peck and start
%% again 90 min after the end of the trial
Trial = Trial + 1;
if Trial <= 3
    
    TimerStop = timer;
    TimerStop.Timerfcn = {@operant_shaping_nextstop};
    TimerStop.BusyMode = 'queue';
    TimerStop.ExecutionMode = 'fixedDelay';
    TimerStop.StartDelay = Test_Duration;

    TimerStart = timer;
    TimerStart.Timerfcn = {@operant_bunchstims_VocCat_nextstart};
    TimerStart.BusyMode = 'queue';
    TimerStart.ExecutionMode = 'fixedDelay';
    TimerStart.StartDelay = Testnextstart_Duration;
else
    TimerStop = timer;
    TimerStop.Timerfcn = {@operant_shaping_finalstop};
    TimerStop.BusyMode = 'queue';
    TimerStop.ExecutionMode = 'fixedDelay';
    TimerStop.StartDelay = Test_Duration;
end
%% These commands are needed to get the program running. 'start(dio)' gets
%  switchreadop_choice_bunchstimsrepertoire involved.
starttime=clock;
fprintf(fid_out1,'The protocol started at %d:%d:%d \n', starttime(4), starttime(5), fix(starttime(6)));
fprintf('********* The protocol of trial %d started at %d:%d:%d *******\n', (Trial-1), starttime(4), starttime(5), fix(starttime(6)));
lasttime=starttime;
start(dio);


