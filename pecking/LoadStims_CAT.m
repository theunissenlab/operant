function [Stims, Stim_list]=LoadStims_CAT(input_dir)
ProbaRe=0.2;
Nstims=1000;
if nargin<1
    input_dir = pwd;
end
input_dir = fullfile(input_dir, 'STIM');
%% Loading filenames in the Stims structure
Stims = struct;
Stims.name = 'Vocalizations';
Stims.sets = struct('name',{},'dir',{}, 'outdir',{},'stims',{});
OutDir = fullfile(input_dir,'OUTSTIMS');% this line set the name of the output directory
fiatdir(OutDir);%this line creates the output directory where prepared Go stims will be stored

% Output Track
TI = clock;
file_name = sprintf('%2d%2d%2d_testVCAT_Stims.txt', TI(4), TI(5),fix(TI(6)));
fid_out = fopen(fullfile(OutDir,file_name), 'wt');
if fid_out == -1
    fprintf(1, 'Error: could not open file name %s\n', file_name);
    pause();
end
fprintf(fid_out,'Stim name\tVoc1\tIVI1\tVoc2\tIVI2\tVoc3\tIVI3\tVoc4\tIVI4\tVoc5\tIVI5\tVoc6\n');


% Find how many stim sets we have and dir each of these sets
Nb_Sets=0;
Folders = dir(input_dir);
for jj = 1:length(Folders)
    Name = Folders(jj).name;
    if ~strcmp('.',Name(1:1)) && ~strcmp('OUTSTIMS',Name) % That is a stim folder
        Nb_Sets=Nb_Sets+1;
        Vocals = struct;
        Vocals.name = Name;
        Vocals.dir = fullfile(input_dir,Vocals.name);
        Vocals.outdir = fullfile(OutDir,Vocals.name);
        fiatdir(Vocals.outdir);
        wav_files = dir(fullfile(Vocals.dir,'*.wav'));
        Vocals.stims = {wav_files.name};
        Stims.sets(Nb_Sets) = Vocals;
    end
end

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
        stim.name = fullfile(set.dir,set.stims{mm});
        Stim_list(stim_idx) = stim;
    end
end

% Compile the calls or songs to make the stimuli and save them under
% OUTSTIMS directories.
for ss = (1:Nb_Sets)
    Set = Stims.sets(ss);
    if strcmp(Set.name, 'SO') || strcmp(Set.name, 'BE')
        N_Stim = 0;
        while N_Stim<Nstims*ProbaRe
            [Y,FS,Bits,Voc,IVI]=stim_creator_song_repertoire(Set, Stim_list);
            N_Stim = N_Stim + 1;
            fprintf(fid_out,'%s_Stim_%d\t%s\t%f\t%s\t%f\t%s\n', Set.name, N_Stim, Voc{1},IVI(1),Voc{2},IVI(2),Voc{3});
            Wav_outfile = fullfile(Set.outdir,sprintf('%s_Stim_%d.wav', Set.name,N_Stim));
            wavwrite(Y,FS,Bits,Wav_outfile);
        end
    else
        N_Stim = 0;
        while N_Stim<Nstims*ProbaRe
            [Y,FS,Bits,Voc,IVI]=stim_creator_repertoire(Set, Stim_list);
            N_Stim = N_Stim + 1;
            fprintf(fid_out,'%s_Stim_%d\t%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f\t%s\t%f\t%s\n', Set.name, N_Stim, Voc{1},IVI(1),Voc{2},IVI(2),Voc{3},IVI(3),Voc{4},IVI(4),Voc{5},IVI(5),Voc{6});
            Wav_outfile = fullfile(Set.outdir,sprintf('%s_Stim_%d.wav',Set.name,N_Stim));
            wavwrite(Y,FS,Bits,Wav_outfile);
        end
    end
end

end