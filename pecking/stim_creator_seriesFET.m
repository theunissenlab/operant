function [Ystim, Voc_sil, Voc_ID]=stim_creator_series(Stim_list, NStims_tot, Stim_indices, Stim_duration, FS, Bits)

if nargin<6
    Bits = 16;
end

if nargin<5
    FS = 44100.0;
end

if nargin<4
    Stim_duration=6; %6seconds
end
if nargin<3
    Stim_indices=1:length(Stim_list);
end
%% wavread the NStims_tot files and treat them
Voc = cell(NStims_tot,1);
Voc_ID.name = cell(NStims_tot,1);
Voc_ID.index = nan(NStims_tot,1);
VocLe=0;
NStims=0;
ii=0;
while NStims<NStims_tot
    ii=ii+1;
    if ii<=length(Stim_indices) 
        Stim_index = Stim_indices(ii);
        Stim_name = Stim_list{Stim_index};
        [Y,Fin] = audioread(Stim_name);
        Info=audioinfo(Stim_name);
    else % Not enough stims so randomly take again from the same pool
        RandLocal = randperm(length(Stim_indices));
        Stim_index = Stim_indices(RandLocal(1));
        Stim_name = Stim_list{Stim_index};
        [Y,Fin] = audioread(Stim_name);
        Info=audioinfo(Stim_name);
    end
    
    if Info.BitsPerSample ~= Bits
        fprintf(1,'Input bits %d do not match output bits %d\n', Info.BitsPerSample, Bits);
    end
    
    if Fin ~= FS
        fprintf(1,'Sampling rate missmatch between input %d and output %d\n', Fin, FS);
        fprintf(1,'Input wave file %s will be resampled\n', Stim_name);
        Y = resample(Y, FS, Fin);
    end
    
    if length(Y(1,:))>1
        Y = (Y(:,1) + Y(:,2))/2; %convert stereo to mono
    end
    % Check that the stim is shorter than 6sec/NStims_tot if not it needs
    % to be cut
    if length(Y)>(FS*Stim_duration/NStims_tot)
        Y = cut_nicely_wav(Y,FS,Stim_duration/NStims_tot);
    end
    % Retrieve call type
    [~,FileName,~]=fileparts(Stim_name);
    [Birdname, remain]=strtok(FileName,'_');
    CallType=strtok(remain,'_');
    
    Y = songfilt_call(Y,FS, 250, 12000, 0, CallType);%bandpass filter from 250Hz to 12000Hz
    Y = cosramp(Y,0.002* FS);%apply a 2ms attenuation on each side
    NStims=NStims+1;
    Voc{NStims}=Y;
    VocLe = VocLe + length(Y);
    Voc_ID.name{NStims} = Stim_name;
    Voc_ID.index(NStims) = Stim_index;

end

%% Insert the vocalizations in an empty waveforms to get silences
Le = FS*Stim_duration - VocLe;
RDelay=rand([1,NStims_tot-1]);
RDelay=RDelay./sum(RDelay);
RDelay = [0 RDelay];
Ystim=zeros(FS*Stim_duration,1);
Voc_sil=nan(NStims_tot,1);
EndInd=0;
for ss=1:NStims_tot
    StartInd=EndInd + floor(RDelay(ss)*Le) +1;
    EndInd=StartInd + length(Voc{ss})-1;
    Ystim(StartInd:EndInd) = Voc{ss};
    Voc_sil(ss) = floor(RDelay(ss)*Le)/FS;
end
Voc_sil = Voc_sil(2:end);
end
