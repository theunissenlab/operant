function switchreadop_choice_shaping(obj,event)

global peck dio starttime fs fid_out2 fid_out3 YGO YNOGO AS TimerFeeder Past_inval ProbaGo

fs = 44100;   % Assume that all files have the same sampling rate
%INTER_FEED_TIME = 10*60;   % Automatic time between feedings in seconds

%% Read from the DIO board
inval = getvalue(dio.line(13:15)); %note: I will need to modify this based on whatever lines are assigned to connect with...
% the pecking key triggers
stamp = clock;
stamp = etime(stamp, starttime);
fprintf(fid_out3,'%.2f\t%d\n',stamp,inval(2));


%% respond with output signal given input
if (inval(2) == 1)
    if (Past_inval(2) == 0)
        n = rand();
        if n <= ProbaGo
            y = YGO;
            AS = update(AS,y,1);
            play(AS)
            fprintf(fid_out2,'%.2f\t%s\n',stamp,'GoStim');
            peck(2) = peck(2) + 1;
            fprintf(1,'Pecked Key %d Total times\n', peck(2));
            fprintf('Go Stim ->');
            if strcmp(get(TimerFeeder, 'Running'), 'on')
                stop(TimerFeeder);
            end
            Song_duration = length(y)/fs;
            TimerFeeder.StartDelay = Song_duration;
            start(TimerFeeder);
            %if strcmp(VocType, 'calls')
            %    [YGO,FSGO]=stim_creator(Stims, Stim_list, 'GO');
            %elseif strcmp(VocType, 'songs')
            %    [YGO,FSGO]=stim_creator_song(Stims, Stim_list, 'GO');
            %end
            
        else
            y = YNOGO;
            AS = update(AS,y,1);
            play(AS)
            fprintf(fid_out2,'%.2f\t%s\n',stamp,'NoGoStim');
            peck(2) = peck(2) + 1;
            fprintf(1,'Pecked Key %d Total times\n', peck(2));
            fprintf('NoGo Stim -> No Seed\n')
            if strcmp(get(TimerFeeder, 'Running'), 'on')
                stop(TimerFeeder);
            end
            %if strcmp(VocType, 'calls')
            %    [YNOGO,FSNOGO]=stim_creator(Stims, Stim_list, 'NOGO');
            %elseif strcmp(VocType, 'songs')
            %    [YNOGO,FSNOGO]=stim_creator_song(Stims, Stim_list, 'NOGO');
            %end
        end
    end
end
Past_inval = inval; %update the past status of the pecking key, so that we can go on

end

            

