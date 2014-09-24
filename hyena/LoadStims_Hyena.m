function [Stims, Stim_list]=LoadStims_Hyena(input_dir, Trial, VocCat)
if ischar(Trial)
    Trial=str2double(Trial);
end
%% Loading filenames in the Stims structure
Stims = struct;
Stims.name = 'Vocalizations';
Stims.sets = struct('name',{},'dir',{}, 'outdir',{},'stims',{});

% Get Go stims (rewarded stims)
Gostims = struct;
Gostims.name = 'GOSTIMS';
Gostims.dir = fullfile(input_dir,Gostims.name);
if Trial==1
    Gostims.outdir = fullfile(input_dir,'OUTGOSTIMS1');% this line set the name of the output directory
elseif Trial==2
    Gostims.outdir = fullfile(input_dir,'OUTGOSTIMS2');
elseif Trial==3
    Gostims.outdir = fullfile(input_dir,'OUTGOSTIMS3');
end
fiatdir(Gostims.outdir);%this line creates the output directory where prepared Go stims will be stored
wav_files = dir(fullfile(Gostims.dir,'*.wav'));
Gostims.stims = {wav_files.name};
Stims.sets(1) = Gostims;


% Get NoGo stims (non rewarded stims)
Nogostims = struct;
Nogostims.name = 'NOGOSTIMS';
Nogostims.dir = fullfile(input_dir,Nogostims.name);
if Trial==1
    Nogostims.outdir = fullfile(input_dir,'OUTNOGOSTIMS1');% this line set the name of the output directory
elseif Trial==2
    Nogostims.outdir = fullfile(input_dir,'OUTNOGOSTIMS2');
elseif Trial==3
    Nogostims.outdir = fullfile(input_dir,'OUTNOGOSTIMS3');
end
fiatdir(Nogostims.outdir);%this line creates the output directory where prepared NoGo stims will be stored
wav_files = dir(fullfile(Nogostims.dir,'*.wav'));
Nogostims.stims = {wav_files.name};
Stims.sets(2) = Nogostims;


%% List all the files in the same structure and give them an index that is
%% saved in the Stims structure
stim_idx = 0;
Stim_list=struct('name',{});

for kk = 1:length(Stims.sets)
    set = Stims.sets(kk);
    n_stims = length(set.stims);
    Stims.sets(kk).stim_indices = stim_idx + (1:n_stims);
    for mm = 1:n_stims
        stim_idx = stim_idx + 1;
        Name = set.stims{mm};
        Type_voc = Name(4:5);
        if ~strcmp(Type_voc, VocCat)
            fprintf('Make sure you enter the right category of vocalizations!!! and tape any key to continue or stop the test');
            pause
        end
        stim.name = fullfile(set.dir,set.stims{mm});
        Stim_list(stim_idx) = stim;
    end
end

end