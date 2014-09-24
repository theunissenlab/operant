% rough outline for operant test for Hyenas

clear all
global Yend NT Nseq ni peck dio starttime lasttime fs fid_out1 fid_out2 fid_out3...
    fid_out4 fid_out6 AS YGO YNOGO TimerFeeder ProbaGo Trial Past_inval TFB TrackFeederBucket once ...
    ClickerRate SystemRate

fs = 44100;   % Assume that all files have the same sampling rate
TIME_UP = 15; %This is the time feeder is up in sec
delayFeeder = 40; % This is the delay after a go stim to activate the feeder
ProbaGo = 0.5; %Probability of getting a Go stim when the bird is pecking
ClickerRate = 0.1; %Frequency to check the clicker in s
SystemRate = 0.1;  %Rate of response
Path=pwd;
OutputPath='C:\Users\Benjamin\Documents\MATLAB\DataPocking';
if ~strcmp(Path,'C:\Users\Benjamin\Documents\MATLAB\codePocking')
    cd C:\Users\Benjamin\Documents\MATLAB\codePocking
end
Input_dir = pwd;
addpath(genpath(fullfile(Input_dir, 'audiostreamer')));

rand('twister', sum(100*clock));

%% Get experiment files
bird_name = input('Hyena''s name?:\nRemember the code:\nCA=Cass\nDE=Denali\nDO=Domino\nDU=Dusty\nGU=Gulliver\nKA=Kadogo\nKO=Kombo\nRO=Rocco\nRB=Robbie\nSC=Scooter\nUR=Ursa\nWI=Winnie\nZA=Zawadi\n', 's');
if isempty(bird_name)
    fprintf(1, 'Invalid Hyena''s name - using "test"\n');
    bird_name = 'test';
end

real_date = input('Today''s date? (yymmdd):', 's');
if isempty(real_date)
    fprintf(1, 'Invalid date - file name will be created without date\n');
    real_date = '000000';
end

VocCat = input('What category of vocalization are you working with?\nGB: Giggles\nWP: Whoops\n', 's');
VocLen = input('How long the vocalizations should be?\nS: short(3sec)\nL: long (10sec)\n', 's');

Trial = input('what is the test #?', 's');
if isempty(Trial)
    fprintf(1, 'Invalid test # - using "0"\n');
    Trial = '0';
end

PG = input('Do you want to change the probability\nto get a rewarded Stim by default it is 0.5?(Y/N)', 's');
if strcmp(PG,'Y')||strcmp(PG, 'y')
    PG = input('Indicate the new value (example: 0.8):', 's');
    ProbaGo = str2num(PG);
end

CR = input('Do you want to change the time response of the system by default it is at the clicker rate 0.1s?(Y/N)', 's');
if strcmp(CR,'Y')||strcmp(CR, 'y')
    CR = input('Indicate the new value (example: 1):', 's');
    SystemRate = str2num(CR);
end

NT = input('How many pocks do you want to run?\n');
NNT = floor(NT/10);
NNR = NT-NNT*10;
Nseq = zeros(NT, 1);
ni=0;
nni=0;
for nn=1:NNT
    Nseq(nni+1:nni+10) = randperm(10)./10;
    nni = nni + 10;
end
Nseq(nni+1:NT) = randperm(NNR)./NNR;

Yend=sin(2*pi*200.*(1:22050)./44100);

TI = clock;
file_name1 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%s_parameters.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)),Trial);
fid_out1 = fopen(fullfile(OutputPath,file_name1), 'wt');
fprintf(fid_out1,'we''re running trials to examine the shaping process in hyena''s.\nThe probability to get a Rewarded Stim is %d.\nWhat''s being recorded is the time stamp (since the begining of the experiment) when the hyena pock its nose in the buckets.\nWe are doing %d trials.\n', ProbaGo, NT);
fprintf(1, 'parameters of this trial will be printed to file %s\n', file_name1);

file_name2 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%s_TimeStampPB.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)),Trial);
fprintf(1, 'Time Stamps of pocking will be printed to file %s\n', file_name2);
fid_out2 = fopen(fullfile(OutputPath,file_name2), 'wt');
if fid_out2 == -1
    fprintf(1, 'Error: could not open file name %s\n', file_name2);
    pause();
end
fprintf(fid_out2,'time(sec)\tVocalizationPlayed\n');

file_name3 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%s_KeyTrack.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), Trial);
fprintf(1, 'Results of key monitoring will be printed to file %s\n', file_name3);
fid_out3 = fopen(fullfile(OutputPath,file_name3), 'wt');
fprintf(fid_out3, 'time(sec)\tActionBucket_status\tFeedingBucket_status\n');

file_name4 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%s_FeederTrack.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), Trial);
fprintf(1, 'Results of Feeder monitoring will be printed to file %s\n', file_name4);
fid_out4 = fopen(fullfile(OutputPath,file_name4), 'wt');
fprintf(fid_out4, 'time(sec)\tFeeder_mouvement\n');

file_name5 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%s_Stims.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)), Trial);
fid_out5 = fopen(fullfile(OutputPath,file_name5), 'wt');
if fid_out5 == -1
    fprintf(1, 'Error: could not open file name %s\n', file_name5);
    pause();
end

file_name6 = sprintf('%s_%s_%2d%2d%2d_shaping_trial%s_TimeStampFB.txt', bird_name, real_date, TI(4), TI(5),fix(TI(6)),Trial);
fprintf(1, 'Time Stamps of feeding will be printed to file %s\n', file_name6);
fid_out6 = fopen(fullfile(OutputPath,file_name6), 'wt');
if fid_out6 == -1
    fprintf(1, 'Error: could not open file name %s\n', file_name6);
    pause();
end
fprintf(fid_out6,'time(sec)\tVocalizationPlayed\n');

%% Define digital IO object
dio = digitalio('mcc', 0);
hwlinein1=addline(dio,0,0,'out');%this line setup the feeder as an output for the computer
hwlineout=addline(dio,0:4,1,'in');%this line setup the two infrared sensors in the buckets and the three pressure detectors in the pocking bucket as input for the computer...
...line 2 is the Feeding Bucket IR sensor, line 3 is the pocking bucket IR sensor...
    ...line 4 to 6 are the four pressure sensors of the pocking bucket
set(dio,'TimerFcn',@switchreadop_Pocking_shaping);
set(dio,'TimerPeriod',ClickerRate);  % Sets the event period to ClickerRate s
putvalue(dio.line(1),0);  % Make sure the feeder is not on high
Past_inval = zeros(1,2); %set the past status of the five sensors to 0

%% Create the timer to bring the feeder up
TimerFeeder = timer;
%TimerFeeder.TimerFcn = {@horseFeeder_on, dio, TFB};
TimerFeeder.TimerFcn = {@horseFeeder_off};
TimerFeeder.BusyMode = 'queue';
TimerFeeder.ExecutionMode = 'singleShot';
TimerFeeder.StartFcn = @(x,y)fprintf('***TimerFeeder ON!***\n');
TimerFeeder.StartDelay = delayFeeder;
fprintf(fid_out1,'Max Delay to activate the feeder after a GoStim is %d s\n',TimerFeeder.StartDelay);
fprintf(1,'***Max Delay to activate the feeder after a GoStim is %d s\n',TimerFeeder.StartDelay);

peck = zeros(1,3);

%% Create the timer that check the feeder bucket status
TrackFeederBucket = timer;
TrackFeederBucket.TimerFcn = {@checkFB, dio};
TrackFeederBucket.BusyMode = 'queue';
TrackFeederBucket.ExecutionMode = 'fixedRate';
TrackFeederBucket.Period = 0.1;
TFB=0; %set the past status of the Feeder bucket status to 0
%% Load song files

if strcmp(VocCat, 'WP')
    if strcmp(VocLen, 'L')
        [YGO,FS1] = wavread('C:\Users\Benjamin\Documents\MATLAB\ShapingWhoops\FR_shapingWh.wav');
        [YNOGO,FS2] = wavread('C:\Users\Benjamin\Documents\MATLAB\ShapingWhoops\OZ_shapingWh.wav');
        fprintf(fid_out5,'The Rewarded Stim used is: C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingWhoops\\FR_shapingWh.wav\nThe NoGo Stim used is C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingWhoops\\OZ_shapingWh.wav\n');
    elseif strcmp(VocLen, 'S')
        if strcmp(bird_name, 'RB')
            [YGO,FS1] = wavread('C:\Users\Benjamin\Documents\MATLAB\ShapingWhoops\GU_WP_test_03_09.wav');
            [YNOGO,FS2] = wavread('C:\Users\Benjamin\Documents\MATLAB\ShapingWhoops\CA_WP_test_02_08.wav');
            fprintf(fid_out5,'The Rewarded Stim used is: C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingWhoops\\GU_WP_test_03_09.wav\nThe NoGo Stim used is C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingWhoops\\CA_WP_test_02_08.wav\n');
        elseif strcmp(bird_name, 'UR')
            [YGO,FS1] = wavread('C:\Users\Benjamin\Documents\MATLAB\ShapingWhoops\WI_WP_test_03_09.wav');
            [YNOGO,FS2] = wavread('C:\Users\Benjamin\Documents\MATLAB\ShapingWhoops\DO_WP_test_10_06.wav');
            fprintf(fid_out5,'The Rewarded Stim used is: C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingWhoops\\WI_WP_test_03_09.wav\nThe NoGo Stim used is C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingWhoops\\DO_WP_test_10_06.wav\n');
        else
            fprintf(1,'WARNING *****Animal name not recognized as Ursa or Robbie******\n*****let''s play with weird whoops*****\n')
            [YGO,FS1] = wavread('C:\Users\Benjamin\Documents\MATLAB\ShapingWhoops\OZ_WP_01_01.wav');
            [YNOGO,FS2] = wavread('C:\Users\Benjamin\Documents\MATLAB\ShapingWhoops\FR_WP_01_03_sfc.wav');
            fprintf(fid_out5,'The Rewarded Stim used is: C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingWhoops\\OZ_WP_01_01.wav\nThe NoGo Stim used is C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingWhoops\\FR_WP_01_03_sfc.wav\n');
        end
    end
elseif strcmp(VocCat, 'GB')
    if strcmp(VocLen, 'L')
        [YGO,FS1] = wavread('C:\Users\Benjamin\Documents\MATLAB\ShapingGiggles\JA_shapingGb.wav');
        [YNOGO,FS2] = wavread('C:\Users\Benjamin\Documents\MATLAB\ShapingGiggles\TE_shapingGb.wav');
        fprintf(fid_out5,'The Rewarded Stim used is: C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingGiggles\\JA_shapingGb.wav\nThe NoGo Stim used is C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingGiggles\\TE_shapingGb.wav\n');
    elseif strcmp(VocLen, 'S')
        if strcmp(bird_name, 'UR')
            [YGO,FS1] = wavread('C:\Users\Benjamin\Documents\MATLAB\ShapingGiggles\DU_GB_test_20.wav');
            [YNOGO,FS2] = wavread('C:\Users\Benjamin\Documents\MATLAB\ShapingGiggles\DE_GB_test_09.wav');
            fprintf(fid_out5,'The Rewarded Stim used is: C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingGiggles\\DU_GB_test_20.wav\nThe NoGo Stim used is C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingGiggles\\DE_GB_test_09.wav\n');
 
        else
            [YGO,FS1] = wavread('C:\Users\Benjamin\Documents\MATLAB\ShapingGiggles\KA_shapingGb.wav');
            [YNOGO,FS2] = wavread('C:\Users\Benjamin\Documents\MATLAB\ShapingGiggles\SC_shapingGb.wav');
            fprintf(fid_out5,'The Rewarded Stim used is: C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingGiggles\\KA_shapingGb.wav\nThe NoGo Stim used is C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingGiggles\\SC_shapingGb.wav\n');
        end
    end
end
AS = audiostreamer(YGO,fs);
if FS1 ~= fs
    fprintf(1,'Sample frequency of rewarded call is %d, different from 44100 Hz: FIX IT!!!!!', FS1);
end
if FS2 ~= fs
    frpintf(1,'Sample frequency of NonRewarded call is %d, different from 44100 Hz: FIX IT!!!!!', FS2);
end
fprintf(1,'The Rewarded Stim used is: C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingWhoops\\FR_shapingWh.wav\nThe NoGo Stim used is C:\\Users\\Benjamin\\Documents\\MATLAB\\ShapingWhoops\\OZ_shapingWh.wav\n');
fprintf(1,'The length of the Go Stim is %.2f s and of the NoGo is %.2f \n', length(YGO)/FS1, length(YNOGO)/FS2);


%% These commands are needed to get the program running. 'start(dio)' gets
% switchreadop_choice_shaping involved.
starttime=clock;
fprintf(fid_out1,'The trial started at %d:%d:%d \n', starttime(4), starttime(5), fix(starttime(6)));
lasttime=starttime;
start(dio);


