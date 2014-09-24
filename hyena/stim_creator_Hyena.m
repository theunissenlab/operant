function [Ystim,Ffirst,Bits,Voc_names,Voc_sil]=stim_creator_Hyena(Stims, Stim_list, Type, VocCat,VocLen)
%set up the right type of stim to be prepared
if strcmp(Type, 'GO')
    set=Stims.sets(1);
elseif strcmp(Type, 'NOGO')
    set=Stims.sets(2);
end

    %preparing the indices of the 3 wav files used to prepare the stim
    Ind = randperm(length(set.stim_indices));
    Indices = set.stim_indices(Ind);

if strcmp(VocLen, 'L')
    %wavread the 3 files and treat them
    Voc = {[] [] []};
    Voc_names = {{} {} {}};
    VocLe=0;
    ii=1;
    ni=1;
    while ni<4
        II=Indices(ii);
        [Y,Fin,Bits] = wavread(Stim_list(II).name);
        if ii ==1
            Ffirst=Fin;
        end
        if Fin==Ffirst
            if length(Y(1,:))>1
                Y = (Y(:,1) + Y(:,2))/2; %convert stereo to mono
            end
            Y = songfilt_Hyena(Y,Fin, 40, 12000, 2, VocCat);%bandpass filter from 250Hz to 12000Hz
            Y = cosramp(Y,0.002* Fin);%apply a 2ms attenuation on each side
            Voc{ii}=Y;
            [Voc_path,Voc_names{ni}] = fileparts(Stim_list(II).name);
            VocLe = VocLe + length(Y);
            ii=ii+1;
            ni=ni+1;
        else
            fprintf('the sample freq of %s is %d while the first stim one is %d, not used for stim construction\n', Stim_list(II).name, Fin, Ffirst);
            ii=ii+1;
        end
    end
    Le = Ffirst*10 - VocLe;
    S1=round(rand*Le/5);
    S2= Le-S1;
    IC1=zeros(S1,1);
    IC2=zeros(S2,1);
    Ystim=[Voc{1};IC1;Voc{2};IC2;Voc{3}];
    Voc_sil = [S1/Ffirst S2/Ffirst];
elseif strcmp(VocLen, 'S')
    %wavread the file and treat it
    Voc_names = {{}};
    ii=1;
    II=Indices(ii);
    [Y,Fin,Bits] = wavread(Stim_list(II).name);
    Ffirst=Fin;
        
    if length(Y(1,:))>1
        Y = (Y(:,1) + Y(:,2))/2; %convert stereo to mono
    end
    Y = songfilt_Hyena(Y,Fin, 40, 12000, 2, VocCat);%bandpass filter from 250Hz to 12000Hz
    Y = cosramp(Y,0.002* Fin);%apply a 2ms attenuation on each side
    Ystim=Y;
    [Voc_path,Voc_names{ii}] = fileparts(Stim_list(II).name);
    Voc_sil = [];
end
