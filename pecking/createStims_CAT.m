function []=createStims_CAT(SubjectName, TestDate, input_dir)
if nargin<1
    SubjectName = input('What is the subject name (ColColxxxxS)?\n', 's');
end
if nargin<2
    TestDate = input('When will the stim be used (yyyymmdd)?\n', 's');
end

if ismac()
    addpath(genpath('/Users/elie/Documents/CODE/operant_matlab/pecking'));
    addpath(genpath('/Users/elie/Documents/CODE/GeneralCode'));
    if nargin<3
        input_dir=cell(2,1);
        input_dir{1} = '/Users/elie/Documents/ManipBerkeley/Recordings/groupRecordings/GoodQuality';
        input_dir{2} = '/Users/elie/Documents/ManipBerkeley/Recordings/ChickRecordings/GoodQuality';
    end
    OutDir = '/Users/elie/Documents/ManipBerkeley/DataPeckingTest/Categories/StimuliUsedTests/OUTSTIMS';% this line set the name of the output directory
else %we are on strfinator or a cluster machine
    addpath(genpath('/auto/fhome/julie/Code/operant/pecking'));
    if nargin<3
        input_dir='/auto/fhome/julie/Documents/FullVocalizationBank';
    end
    OutDir = '/auto/tdrive/julie/StimuliPeckingTest/CallCategories/OUTSTIMS';% this line set the name of the output directory
end



system(sprintf('rm -r %s\n', OutDir));%this line removes the output directory in case there was already one
fiatdir(OutDir);%this line creates the output directory where prepared stims will be stored

% Output Trackfile
TI = clock;
file_name = sprintf('%s_%s_%4d%2d%2d_%2d%2d%2d_testVCAT_Stims.txt',SubjectName,TestDate,TI(1),TI(2),TI(3), TI(4), TI(5),fix(TI(6)));
USPosition = strfind(file_name,'_');
Position = USPosition(2) + [1 5 7 10 12 14];
AddzeroP=find(TI<10);
file_name(Position(AddzeroP))='0';
fid_out = fopen(fullfile(OutDir,file_name), 'wt');
if fid_out == -1
    fprintf(1, 'Error: could not open file name %s\n', file_name);
    pause();
end
fprintf(fid_out,'Stim name\tVoc1\tIVI1\tVoc2\tIVI2\tVoc3\tIVI3\tVoc4\tIVI4\tVoc5\tIVI5\tVoc6\n');

%% List all the files from the bank
if iscell(input_dir)
    WaveNames = {};
    for dd=1:length(input_dir)
        WN_temp=dir(fullfile(input_dir{dd}, '*.wav'));
        for ww=1:length(WN_temp)
            WaveNames = [WaveNames fullfile(input_dir{dd}, WN_temp(ww).name)];
        end
    end
else
    WN_temp = dir(fullfile(input_dir, '*.wav'));
    WaveNames = cell(length(WN_temp),1);
    for ww=1:length(WN_temp)
        WaveNames{ww} = fullfile(input_dir, WN_temp(ww).name);
    end
end

%% Identify Vocalizer, CallType and CallID for each file
Vocalizer = cell(size(WaveNames));
CallType = Vocalizer;
CallID = Vocalizer;
for ss=1:length(WaveNames)
    [~,WaveName,ext] = fileparts(WaveNames{ss});
    WaveName=[WaveName ext];
    Vocalizer{ss} = WaveName(1:10);
    ParseCT1=strfind(WaveName,'-');
    ParseCT2=strfind(WaveName,'_');
    ParseCT = sort([ParseCT1 ParseCT2]);
    CallType{ss} =  WaveName(ParseCT(2)+1:ParseCT(2)+2);
    if length(ParseCT)==4
        CallID{ss} =  WaveName(ParseCT(end-1)+1:ParseCT(end)+2);
    else
        CallID{ss} =  WaveName(ParseCT(end)+1:ParseCT(end)+2);
    end
end

% identify the unique CallTypes, UniqueVocalizer
[UniqVocalizer, ~, VocalizerCode]=unique(Vocalizer);
[UniqCallType, ~, CallTypeCode]=unique(CallType);

%% Go through call types an identify the number of vocalizers and the median
% number of renditions per vocalizer
NB_Vocalizers=nan(size(UniqCallType));
for ct=1:length(UniqCallType)
    fprintf(1, 'Call Type %s\n',UniqCallType{ct});
    Local_CT = find(CallTypeCode==ct);
    Local_UVoc = unique(VocalizerCode(Local_CT));
    NB_Vocalizers(ct) = length(Local_UVoc);
    fprintf(1,'# of vocalizers: %d\n', NB_Vocalizers(ct));
    Local_Rend = nan(NB_Vocalizers(ct),1);
    for vv=1:NB_Vocalizers(ct)
        Local_Rend(vv)=sum((CallTypeCode==ct).*(VocalizerCode==Local_UVoc(vv)));
    end
    fprintf(1,'median # of renditions: %f\n',median(Local_Rend));
end

% We are not keeping the call Type WC which was pretty unique to a
% copulation whine situation
UniqCallTypeCode = 1:length(UniqCallType);
UniqCallTypeCode(11) = [];

% Minimum number of vocalizers per category
MinVoc = min(NB_Vocalizers(UniqCallTypeCode));

%% For each category and each vocalizer, let's build 10 stimuli taking
% randomly from the pool of available renditions
for cc=1:length(UniqCallTypeCode)
    ct=UniqCallTypeCode(cc);
    CT_local = UniqCallType{ct};
    fprintf('Compiling %s stims\n',CT_local);
    Local_CT = find(CallTypeCode==ct);
    Local_UVoc = unique(VocalizerCode(Local_CT));
    RandVocOrder = randperm(length(Local_UVoc));
    for vv=1:MinVoc 
        LocalVocalizer = Local_UVoc(RandVocOrder(vv)); % Choose randomly a vocalizer
        fprintf('Vocalizer %d/%d: %s\n',vv, MinVoc,UniqVocalizer{LocalVocalizer})
        Local_Voc = find(VocalizerCode==LocalVocalizer);% identify the calls in the bank that correspond to that vocalizer
        Local_Calls = intersect(Local_Voc, Local_CT); % These are all the rendition of calls of that call type from that particular individual
        % Create 10 stims from these calls
        if strcmp(CT_local, 'So') || strcmp(CT_local, 'Be')
            for ss=1:10
                RandCallsOrder = randperm(length(Local_Calls));
                [Y,FS,Bits,IVI, Voc_id]=stim_creator_series(WaveNames,3,Local_Calls(RandCallsOrder));
                fprintf(fid_out,'%s_Stim_%s_%d\t%s\t%f\t%s\t%f\t%s\n', CT_local,UniqVocalizer{LocalVocalizer}, ss, Voc_id.name{1},IVI(1),Voc_id.name{2},IVI(2),Voc_id.name{3});
                Wav_outfile = fullfile(OutDir,sprintf('%s_Stim_%d_%s_%s%s%s.wav', CT_local,ss,UniqVocalizer{LocalVocalizer},CallID{Voc_id.index(1)},CallID{Voc_id.index(2)},CallID{Voc_id.index(3)}));
                audiowrite(Wav_outfile,Y,FS,'BitsPerSample',Bits);
            end
        else
            for ss=1:10
                RandCallsOrder = randperm(length(Local_Calls));
                [Y,FS,Bits,IVI, Voc_id]=stim_creator_series(WaveNames,6,Local_Calls(RandCallsOrder));
                fprintf(fid_out,'%s_Stim_%s_%d\t%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f\t%s\n', CT_local,UniqVocalizer{LocalVocalizer}, ss, Voc_id.name{1},IVI(1),Voc_id.name{2},IVI(2),Voc_id.name{3},IVI(3),Voc_id.name{4},IVI(4),Voc_id.name{5},IVI(5),Voc_id.name{6});
                Wav_outfile = fullfile(OutDir,sprintf('%s_Stim_%d_%s_%s%s%s%s%s%s.wav',CT_local,ss,UniqVocalizer{LocalVocalizer},CallID{Voc_id.index(1)},CallID{Voc_id.index(2)},CallID{Voc_id.index(3)},CallID{Voc_id.index(4)},CallID{Voc_id.index(5)},CallID{Voc_id.index(6)}));
                audiowrite(Wav_outfile,Y,FS,'BitsPerSample',Bits);
            end
        end
    end
end
fclose(fid_out);
% Moving the file containing the stims used to another safer place
if ismac()
    system(sprintf('mv %s /Users/elie/Documents/ManipBerkeley/DataPeckingTest/Categories/StimuliUsedTests/' ,fullfile(OutDir,file_name)))
else
    system(sprintf('mv %s /auto/tdrive/julie/StimuliPeckingTest/CallCategories/',fullfile(OutDir,file_name)));
end
    
end