function [Stims, Stim_list]=LoadStims_VocCat(input_dir, Trial, TodayVoc)
if ischar(Trial)
    Trial=str2double(Trial);
end
input_dir = fullfile(input_dir, 'STIM');
%% Loading filenames in the Stims structure
Stims = struct;
Stims.name = 'Vocalizations';
Stims.sets = struct('name',{},'dir',{}, 'outdir',{},'stims',{});
if Trial==1
        GoOutDir = fullfile(input_dir,'OUTGOSTIMS1');% this line set the name of the output directory
    elseif Trial==2
        GoOutDir = fullfile(input_dir,'OUTGOSTIMS2');
    elseif Trial==3
        GoOutDir = fullfile(input_dir,'OUTGOSTIMS3');
end
fiatdir(GoOutDir);%this line creates the output directory where prepared Go stims will be stored

if Trial==1
    NoGoOutDir = fullfile(input_dir,'OUTNOGOSTIMS1');% this line set the name of the output directory
elseif Trial==2
    NoGoOutDir = fullfile(input_dir,'OUTNOGOSTIMS2');
elseif Trial==3
    NoGoOutDir = fullfile(input_dir,'OUTNOGOSTIMS3');
end
fiatdir(NoGoOutDir);%this line creates the output directory where prepared NoGo stims will be stored


if TodayVoc(1)==0
    % Get Go songs (rewarded stims)
    Gostims = struct;
    Gostims.name = 'GOSONGS';
    Gostims.dir = fullfile(input_dir,Gostims.name);
    Gostims.outdir = GoOutDir;
    wav_files = dir(fullfile(Gostims.dir,'*.wav'));
    Gostims.stims = {wav_files.name};
    Stims.sets(1) = Gostims;
end

if TodayVoc(2)==0
    % Get Go BEGGING (rewarded stims)
    Gostims = struct;
    Gostims.name = 'GOBE';
    Gostims.dir = fullfile(input_dir,Gostims.name);
    Gostims.outdir = GoOutDir;% this line set the name of the output directory
    wav_files = dir(fullfile(Gostims.dir,'*.wav'));
    Gostims.stims = {wav_files.name};
    Stims.sets(2) = Gostims;
end

if TodayVoc(3) ==0
    % Get Go DC (rewarded stims)
    Gostims = struct;
    Gostims.name = 'GODC';
    Gostims.dir = fullfile(input_dir,Gostims.name);
    Gostims.outdir = GoOutDir;
    wav_files = dir(fullfile(Gostims.dir,'*.wav'));
    Gostims.stims = {wav_files.name};
    Stims.sets(3) = Gostims;
end

if TodayVoc(4)==0
    % Get Go TETS (rewarded stims)
    Gostims = struct;
    Gostims.name = 'GOTETS';
    Gostims.dir = fullfile(input_dir,Gostims.name);
    Gostims.outdir = GoOutDir;
    wav_files = dir(fullfile(Gostims.dir,'*.wav'));
    Gostims.stims = {wav_files.name};
    Stims.sets(4) = Gostims;
end

if TodayVoc(5)==0
    % Get Go NESTC (rewarded stims)
    Gostims = struct;
    Gostims.name = 'GONESTC';
    Gostims.dir = fullfile(input_dir,Gostims.name); 
    Gostims.outdir = GoOutDir;
    wav_files = dir(fullfile(Gostims.dir,'*.wav'));
    Gostims.stims = {wav_files.name};
    Stims.sets(5) = Gostims;
end

if TodayVoc(6)==0
    % Get Go WHINES (rewarded stims)
    Gostims = struct;
    Gostims.name = 'GOWHINES';
    Gostims.dir = fullfile(input_dir,Gostims.name);
    Gostims.outdir = GoOutDir;
    wav_files = dir(fullfile(Gostims.dir,'*.wav'));
    Gostims.stims = {wav_files.name};
    Stims.sets(6) = Gostims;
end

if TodayVoc(7)==0
    % Get Go THUCKS (rewarded stims)
    Gostims = struct;
    Gostims.name = 'GOTHUCKS';
    Gostims.dir = fullfile(input_dir,Gostims.name);
    Gostims.outdir = GoOutDir;
    wav_files = dir(fullfile(Gostims.dir,'*.wav'));
    Gostims.stims = {wav_files.name};
    Stims.sets(7) = Gostims;
end

if TodayVoc(8)==0
    % Get Go AGGC (rewarded stims)  
    Gostims = struct;
    Gostims.name = 'GOAGGC';
    Gostims.dir = fullfile(input_dir,Gostims.name);
    Gostims.outdir = GoOutDir;
    wav_files = dir(fullfile(Gostims.dir,'*.wav'));
    Gostims.stims = {wav_files.name};
    Stims.sets(8) = Gostims;
end

if TodayVoc(9)==0
    % Get Go DISC (rewarded stims)
    Gostims = struct;
    Gostims.name = 'GODISC';
    Gostims.dir = fullfile(input_dir,Gostims.name);
    Gostims.outdir = GoOutDir;% this line set the name of the output directory
    wav_files = dir(fullfile(Gostims.dir,'*.wav'));
    Gostims.stims = {wav_files.name};
    Stims.sets(9) = Gostims;
end

if TodayVoc(10)==0
    % Get Go LTC (rewarded stims)
    Gostims = struct;
    Gostims.name = 'GOLTC';
    Gostims.dir = fullfile(input_dir,Gostims.name);
    Gostims.outdir = GoOutDir;% this line set the name of the output directory
    wav_files = dir(fullfile(Gostims.dir,'*.wav'));
    Gostims.stims = {wav_files.name};
    Stims.sets(10) = Gostims;
end

if TodayVoc(1)==1
    % Get NoGo SONGS (non rewarded stims)
    Nogostims = struct;
    Nogostims.name = 'NOGOSONGS';
    Nogostims.dir = fullfile(input_dir,Nogostims.name);
    Nogostims.outdir = NoGoOutDir;
    wav_files = dir(fullfile(Nogostims.dir,'*.wav'));
    Nogostims.stims = {wav_files.name};
    Stims.sets(11) = Nogostims;
end

if TodayVoc(2)==1
    % Get NoGo Begging (non rewarded stims)
    Nogostims = struct;
    Nogostims.name = 'NOGOBE';
    Nogostims.dir = fullfile(input_dir,Nogostims.name);
    Nogostims.outdir = NoGoOutDir;% this line set the name of the output directory
    wav_files = dir(fullfile(Nogostims.dir,'*.wav'));
    Nogostims.stims = {wav_files.name};
    Stims.sets(12) = Nogostims;
end

if TodayVoc(3)==1
    % Get NoGo DC (non rewarded stims)
    Nogostims = struct;
    Nogostims.name = 'NOGODC';
    Nogostims.dir = fullfile(input_dir,Nogostims.name);
    Nogostims.outdir = NoGoOutDir;
    wav_files = dir(fullfile(Nogostims.dir,'*.wav'));
    Nogostims.stims = {wav_files.name};
    Stims.sets(13) = Nogostims;
end

if TodayVoc(4)==1
    % Get NoGo TETS (non rewarded stims)
    Nogostims = struct;
    Nogostims.name = 'NOGOTETS';
    Nogostims.dir = fullfile(input_dir,Nogostims.name);
    Nogostims.outdir = NoGoOutDir;
    wav_files = dir(fullfile(Nogostims.dir,'*.wav'));
    Nogostims.stims = {wav_files.name};
    Stims.sets(14) = Nogostims;
end

if TodayVoc(5)==1
    % Get NoGo NESTC (non rewarded stims)
    Nogostims = struct;
    Nogostims.name = 'NOGONESTC';
    Nogostims.dir = fullfile(input_dir,Nogostims.name);
    Nogostims.outdir = NoGoOutDir;
    wav_files = dir(fullfile(Nogostims.dir,'*.wav'));
    Nogostims.stims = {wav_files.name};
    Stims.sets(15) = Nogostims;
end

if TodayVoc(6)==1
    % Get NoGo WHINES (non rewarded stims)
    Nogostims = struct;
    Nogostims.name = 'NOGOWHINES';
    Nogostims.dir = fullfile(input_dir,Nogostims.name);
    Nogostims.outdir = NoGoOutDir;
    wav_files = dir(fullfile(Nogostims.dir,'*.wav'));
    Nogostims.stims = {wav_files.name};
    Stims.sets(16) = Nogostims;
end

if TodayVoc(7)==1
    % Get NoGo THUCKS (non rewarded stims)
    Nogostims = struct;
    Nogostims.name = 'NOGOTHUCKS';
    Nogostims.dir = fullfile(input_dir,Nogostims.name);
    Nogostims.outdir = NoGoOutDir;
    wav_files = dir(fullfile(Nogostims.dir,'*.wav'));
    Nogostims.stims = {wav_files.name};
    Stims.sets(17) = Nogostims;
end

if TodayVoc(8)==1
    % Get NoGo AGGC (non rewarded stims)
    Nogostims = struct;
    Nogostims.name = 'NOGOAGGC';
    Nogostims.dir = fullfile(input_dir,Nogostims.name);
    Nogostims.outdir = NoGoOutDir;
    wav_files = dir(fullfile(Nogostims.dir,'*.wav'));
    Nogostims.stims = {wav_files.name};
    Stims.sets(18) = Nogostims;
end

if TodayVoc(9)==1
    % Get NoGo DISC (non rewarded stims)
    Nogostims = struct;
    Nogostims.name = 'NOGODISC';
    Nogostims.dir = fullfile(input_dir,Nogostims.name);
    Nogostims.outdir = NoGoOutDir;% this line set the name of the output directory
    wav_files = dir(fullfile(Nogostims.dir,'*.wav'));
    Nogostims.stims = {wav_files.name};
    Stims.sets(19) = Nogostims;
end

if TodayVoc(10)==1
    % Get NoGo LTC (non rewarded stims)
    Nogostims = struct;
    Nogostims.name = 'NOGOLTC';
    Nogostims.dir = fullfile(input_dir,Nogostims.name);
    Nogostims.outdir = NoGoOutDir;% this line set the name of the output directory
    wav_files = dir(fullfile(Nogostims.dir,'*.wav'));
    Nogostims.stims = {wav_files.name};
    Stims.sets(20) = Nogostims;
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

end