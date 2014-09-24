function switchreadop_choice_bunchstimsVocCat_auto(obj,event)

global peck dio starttime fs fid_out1 fid_out2 fid_out3 YGO YNOGO AS...
    TimerFeeder Past_inval Stims ProbaGo IndGoStims IndNoGoStims GO_List...
    NOGO_List TimerStart TimerStop Trial TodayVoc

fs = 44100;   % Assume that all files have the same sampling rate
%% Read from the DIO board
inval = getvalue(dio.line(13:15)); %note: I will need to modify this based on whatever lines are assigned to connect with...
% the pecking key triggers
CurrTime = clock;
stamp = etime(CurrTime, starttime);
fprintf(fid_out3,'%.2f\t%d\n',stamp,inval(2));

%% respond with output signal given input
if (inval(2) == 1)
    if (Past_inval(2) == 0)
        if peck(2)==0
            fprintf(fid_out1,'The trial started with the first peck at %d:%d:%d \n', CurrTime(4), CurrTime(5), fix(CurrTime(6)));
            fprintf(1,'The trial started with the first peck at %d:%d:%d \n', CurrTime(4), CurrTime(5), fix(CurrTime(6)));
            start(TimerStop);
            if Trial<= 3
                start(TimerStart);
            end
        end
        n = rand();
        if n <= ProbaGo
            y = YGO;
            AS = update(AS,y,1);
            play(AS)
            fprintf(fid_out2,'%.2f\t%s\t%d\n',stamp,'GO Stim',GO_List(IndGoStims));
            peck(2) = peck(2) + 1;
            fprintf(1,'Pecked Key %d Total times\n', peck(2));
            fprintf('Go Stim->');
            if strcmp(get(TimerFeeder, 'Running'), 'on')
                stop(TimerFeeder);
            end
            Song_duration = length(y)/fs;
            TimerFeeder.StartDelay = Song_duration;
            start(TimerFeeder);
            IndGoStims = IndGoStims + 1;
            SETS=find(~TodayVoc);
            Wav_infileGo = dir(fullfile(Stims.sets(SETS(1)).outdir,sprintf('GoStim_%d_*.wav',GO_List(IndGoStims))));
            Wav_infileGo = fullfile(Stims.sets(SETS(1)).outdir,Wav_infileGo.name);
            [YGO,FSGO] = wavread(Wav_infileGo);
            
        else
            y = YNOGO;
            AS = update(AS,y,1);
            play(AS)
            fprintf(fid_out2,'%.2f\t%s\t%d\n',stamp,'NOGO Stim', NOGO_List(IndNoGoStims));
            peck(2) = peck(2) + 1;
            fprintf(1,'Pecked Key %d Total times\n', peck(2));
            fprintf('NoGo Stim -> No Seed\n')
            if strcmp(get(TimerFeeder, 'Running'), 'on')
                stop(TimerFeeder);
            end
            IndNoGoStims = IndNoGoStims +1;
            SETS=find(TodayVoc);
            Wav_infileNoGo = dir(fullfile(Stims.sets(SETS(1)+10).outdir,sprintf('NoGoStim_%d_*.wav',NOGO_List(IndNoGoStims))));
            Wav_infileNoGo = fullfile(Stims.sets(SETS(1)+10).outdir,Wav_infileNoGo.name);
            [YNOGO,FSNOGO] = wavread(Wav_infileNoGo);
        end
    end
end
if ~inval(2)==2
    Past_inval = inval; %update the past status of the peckin key, so that we can go on
end
end

            

