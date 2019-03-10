%% Create song stimuli from raw song files using stim_creator_series.m

% Input and output folders
inputDir = '/Users/frederictheunissen/Documents/Data/Pecking Test/stimuli/raw songs/';
outputDir = '/Users/frederictheunissen/Documents/Data/Pecking Test/stimuli/Processed Songs';

% Path to pecking matlab code
addpath(genpath('/Users/frederictheunissen/Documents/Code/operant/pecking'));
nStims = 10;   % Number of composite stims generate per bird

% To make standard wave files
FS = 44100.0;   % CD Sampling Rate
Bits = 16;      % 16 bits per sample

% Values for composite song
Duration = 6;   % 6 seconds
nBase = 3;     % Number of baseline sounds in the final sound of fixed duration

%%

% Find the wav files in the input folder.
inputFiles = dir(fullfile(inputDir, '*.wav'));
nFiles = length(inputFiles);

birdNames = cell(nFiles,1);
waveNames = cell(nFiles,1);
for ww= 1:nFiles
    birdNames{ww} = strtok(inputFiles(ww).name, '_');
    waveNames{ww} = fullfile(inputDir, inputFiles(ww).name);
end

%%
% Make new stims by calling stim_creator_seriesFET
uniqueBirds = unique(birdNames);
nBirds = length(uniqueBirds);

for ib = 1:nBirds
    ind = find(strcmp(birdNames,uniqueBirds{ib}));
    
    for is = 1:nStims
        indFile = ind(randi(length(ind), [1,length(ind)]));
        [Y, Voc_sil, Voc_ID] = stim_creator_seriesFET(waveNames, nBase, indFile, Duration, FS, Bits);
        
        % Save the wave file - note that this name only works when nStims
        % >=3 and it might not make sense for > 3
        Wav_outfile = fullfile(outputDir,sprintf('DC_Stim_%d_%s_%d%d%d.wav', is, uniqueBirds{ib},indFile(1),indFile(2), indFile(3)));
        audiowrite(Wav_outfile,Y,FS,'BitsPerSample',Bits);
    end
    
end
    