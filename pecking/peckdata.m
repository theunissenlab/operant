function x = peckdata(textfile)
% Gives the Go and No Go Song Interruption data
%Import data into matlab
fid = fopen(textfile);
header = textscan(fid, '%s\t%s\t%s\t', 1);
data = textscan(fid, '%f%s%s%s');
fclose(fid);
%Get the time difference between pecks
n = length(data{1});
time = data{1};
timedif = [time(2:n); 0] - time;
% Make a logical vector that will tell you whether an interruption occurred
% or not. For Interruption, 1 = Interruption and 0 = No Interruption
Interruptionmax = timedif(1:n-1) < 6;% Delay below 6 seconds (length of the playback) is considered as an interruption
Interruptionmin = timedif(1:n-1) > 0.19;%This line is to make sure that long pressure of the button would not be counted as interruptions. Added on 09/14/2012
Interruption = Interruptionmax.*Interruptionmin;
Interruption = double(Interruption);
InterruptionInd = find(Interruption);
if numel(InterruptionInd)>0
    InterruptionFirst = InterruptionInd(1);
else
    InterruptionFirst = 0;
end

%Convert the song played to binary vector. For BinarySong, 1 = Go and 0 =
%No Go and get total number of pecks, Go Songs, and No Go Songs
Song = data{2};
Songchar = char(Song);
SongDouble = double(Songchar);
%SongDouble(:,2:end) = [];
BinarySong = SongDouble(:,1) < 75;
BinarySong = double(BinarySong);
TotalGo = sum(BinarySong);
TotalNoGo = length(BinarySong) - TotalGo;
Totalpecks = length(BinarySong);
BinSong = BinarySong(1:end-1);
% Number of Go Song Interruptions, Mean and STD delay for Go Interruption 
GoInt = Interruption .* BinSong;
NumGoInt = sum(GoInt);
if NumGoInt>0
    IndicesGo = find(GoInt);
    GoInt1Ind = IndicesGo(1);
    GoIntFirst = sum(BinSong(1:GoInt1Ind));
    GoIntFirstTime = time(GoInt1Ind)-time(1);
    DelayGoInt = double(GoInt).*double(timedif(1:n-1));
    MeanDelayGoInt = sum(DelayGoInt)/NumGoInt;
    STDDelayGoInt = std(DelayGoInt(IndicesGo));
end

%Number of No Go Song Interruptions. For InvBin, 0 = Go and 1 = No Go
InvBin = ~BinSong;
NoGoInt = Interruption .* InvBin;
NumNoGoInt = sum (NoGoInt);
if NumNoGoInt>0
    IndicesNoGo = find(NoGoInt);
    NoGoInt1Ind = IndicesNoGo(1);
    NoGoIntFirst = sum(InvBin(1:NoGoInt1Ind));
    NoGoIntFirstTime = time(NoGoInt1Ind)-time(1);
    DelayNoGoInt = double(NoGoInt).*double(timedif(1:n-1));
    MeanDelayNoGoInt = sum(DelayNoGoInt)/NumNoGoInt;
    STDDelayNoGoInt = std(DelayNoGoInt(IndicesNoGo));
end

%Number of Go Song Non-Interruptions. For InvInt, 0 = Interruption and 1 =
%No Interruption
InvInt = ~Interruption;
GoNoInt = InvInt .* BinSong;
NumGoNoInt = sum(GoNoInt);
%Number of No Go Song Non-Interruptions. 
NoGoNoInt = InvInt .* InvBin;
NumNoGoNoInt = sum(NoGoNoInt);
%Percent of the time Go Song was played.
PecGoSongPlayed = (TotalGo / Totalpecks) * 100;
%Percent of the time Go Song was interrupted
PecGoInt = (NumGoInt / TotalGo) * 100;
%Percent of the time No Go Song was interrupted
PecNoGoInt = (NumNoGoInt / TotalNoGo) * 100;
%Probability to interrupt a stim
ProbaInt = (NumNoGoInt+NumGoInt)./Totalpecks;
%
ZScore = (NumGoInt / TotalGo - NumNoGoInt / TotalNoGo)./sqrt(ProbaInt.*(1-ProbaInt).*(1/TotalGo + 1/TotalNoGo));
% pd = makedist('Normal');

pVal = 2*(1-cdf('norm', abs(ZScore),0,1));   % A two tailed test

%summary
fprintf('%% of NoGo interruptions: %f %%\n',PecNoGoInt);
fprintf('%% of Go interruptions: %f %%\n', PecGoInt);
fprintf('Total number of pecks: %d\n', Totalpecks);
fprintf('Number of NoGo stims: %d\n', TotalNoGo);
fprintf('Number of Go stims: %d\n', TotalGo);
fprintf('%% Go Stim: %f %%\n', PecGoSongPlayed);
fprintf('Number of NoGo interruptions: %d\n', NumNoGoInt);
fprintf('Number of Go interruptions: %d\n', NumGoInt);
fprintf('Zscore for equality of two binomial proportions = %.2f p = %.2g (Two sided)\n', ZScore, pVal);
fprintf('Index of first interrupted stim: %d\n', InterruptionFirst);
if NumNoGoInt>0
    fprintf('Index of the first NoGo stim interrupted: %d\n', NoGoIntFirst);
end
if NumGoInt>0
    fprintf('Index of the first Go stim interrupted: %d\n', GoIntFirst);
end
if NumNoGoInt>0
    fprintf('Delay to first interrupt the NoGo stim from the begining of trial: %f seconds\n', NoGoIntFirstTime);
end
if NumGoInt>0
    fprintf('Delay to first interrupt the Go stim from the begining of trial: %f seconds\n', GoIntFirstTime);
end
if NumNoGoInt>0
    fprintf('Delay to interrupt NoGo stim from the stim begining (mean+/- SD in sec): %f +/- %f\n', MeanDelayNoGoInt,STDDelayNoGoInt);
end
if NumGoInt>0
  fprintf('Delay to interrupt Go stim from the stim begining (mean+/- SD in sec): %f +/- %f\n', MeanDelayGoInt,STDDelayGoInt);
end
end




