function [Ystim,FS,Bits,Voc_names,Voc_sil]=stim_creator_repertoire(set, Stim_list)

%preparing the indices of the 6 wav files used to prepare the stim
Ind = randperm(length(set.stim_indices));
Indices = set.stim_indices(Ind);


%wavread the 6 files and treat them
Voc = {[] [] [] [] [] []};
Voc_names = {{} {} {} {} {} {}};
VocLe=0;
for ii=(1:6)
    II=Indices(ii);
    [Path,Voc_name] = fileparts(Stim_list(II).name);
    VocCat = Voc_name(19:20);
    [Y,Fin,Bits] = wavread(Stim_list(II).name);
    if length(Y(1,:))>1
        Y = (Y(:,1) + Y(:,2))/2; %convert stereo to mono
    end
    Y = songfilt_call(Y,Fin, 250, 12000, 0, VocCat);%bandpass filter from 250Hz to 12000Hz
    Y = cosramp(Y,0.002* Fin);%apply a 2ms attenuation on each side
    Voc{ii}=Y;
    Voc_names{ii} = Stim_list(II).name;
    VocLe = VocLe + length(Y);
    FS=Fin;
end
Le = Fin*6 - VocLe;
S1=round(rand*Le/5);
S2=round(rand*Le/5);
S3=round(rand*Le/5);
S4=round(rand*Le/5);
S5= Le-S2-S1-S3-S4;
IC1=zeros(S1,1);
IC2=zeros(S2,1);
IC3=zeros(S3,1);
IC4=zeros(S4,1);
IC5=zeros(S5,1);
Ystim=[Voc{1};IC1;Voc{2};IC2;Voc{3};IC3;Voc{4};IC4;Voc{5};IC5;Voc{6}];
Voc_sil = [S1/Fin S2/Fin S3/Fin S4/Fin S5/Fin];
end
