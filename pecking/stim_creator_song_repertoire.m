function [Ystim,FS,Bits,Voc_names,Voc_sil]=stim_creator_song_repertoire(set, Stim_list)

%preparing the indices of the 3 wav files used to prepare the stim
Ind = randperm(length(set.stim_indices));
Indices = set.stim_indices(Ind);


%wavread the 3 files and treat them
Voc = {[] [] []};
Voc_names = {{} {} {}};
VocLe=0;
for ii=(1:3)
    II=Indices(ii);
    [Y,Fin,Bits] = wavread(Stim_list(II).name);
    if length(Y(1,:))>1
        Y = (Y(:,1) + Y(:,2))/2; %convert stereo to mono
    end
    Y = songfilt(Y,Fin, 250, 12000, 0);%bandpass filter from 250Hz to 12000Hz
    Y = cosramp(Y,0.002* Fin);%apply a 2ms attenuation on each side
    Voc{ii}=Y;
    Voc_names{ii} = Stim_list(II).name;
    VocLe = VocLe + length(Y);
    FS=Fin;
end
Le = Fin*6 - VocLe;
S1=round(rand*Le/5);
S2= Le-S1;
IC1=zeros(S1,1);
IC2=zeros(S2,1);
Ystim=[Voc{1};IC1;Voc{2};IC2;Voc{3}];
Voc_sil = [S1/Fin S2/Fin];
end
