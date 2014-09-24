function switchreadop_Pocking_shaping(obj,event)

global NT Nseq ni peck dio starttime fs fid_out2 fid_out3 fid_out6 YGO YNOGO AS TimerFeeder Past_inval ProbaGo TrackFeederBucket TFB once

fs = 44100;   % Assume that all files have the same sampling rate
%INTER_FEED_TIME = 10*60;   % Automatic time between feedings in seconds

%% Read from the DIO board
inval(1) = getvalue(dio.line(3));%line 3 is the Pocking Bucket IR sensor
inval(2) = getvalue(dio.line(2));%line2 is the feeding bucket IR sensor
inval(3:5) = getvalue(dio.line(4:6));%line 4 to 6 are the three pressure sensors of the pocking bucket
stamp = clock;
stamp = etime(stamp, starttime);
fprintf(fid_out3,'%.2f\t%d\t%d\t%d\t%d\t%d\n',stamp,inval(1), inval(3:5),inval(2));
Pocking=inval(1); %IR only
%Pocking=sum(inval(3:5))+ inval(1); %with IR sensor
%Pocking=sum(inval(3:5));%without IR sensor

%% respond with output signal given input for the Pocking Bucket
if (Pocking > 0)
    if (Past_inval(1) == 0)
        if ni == NT
            fprintf(fid_out2,'%.2f\t%s\n',stamp,'FinalPock');
            PockingTest_shaping_finalstop
            return
        end
        ni = ni + 1;
        n = Nseq(ni);
        if strcmp(TimerFeeder.Running, 'on')
            stop(TimerFeeder)
        end
        if strcmp(TrackFeederBucket.Running,'on')
            stop(TrackFeederBucket)
        end
        if strcmp(AS.Running, 'on')
            fprintf(1, ' Interruption\n');
        end
        if n <= ProbaGo
            y = YGO;
            AS = update(AS,y,1);
            play(AS)
            fprintf(fid_out2,'%.2f\t%s\n',stamp,'GoStim');
            peck(1) = peck(1) + 1;

            if strcmp(get(TimerFeeder, 'Running'), 'on')
                stop(TimerFeeder);
            end
            
            fprintf(1,'Total # of pocks since begining: %d\n', peck(1));
            fprintf('Go Stim ->');
            %Song_duration = length(y)/fs;
            %TimerFeeder.StartDelay = Song_duration; %these two lines where
            %previously delaying the feeder opening of the duration of the
            %vocalization now it's setup for a fix duration of 20s
            start(TimerFeeder);
            TFB = 0;%initialize the variable that keeps track of the feeding bucket after triggering the gostim
            once = 0;%initialize the variable that keeps track of the number of activation of the feeder
            start(TrackFeederBucket);
        else
            y = YNOGO;
            AS = update(AS,y,1);
            play(AS)
            fprintf(fid_out2,'%.2f\t%s\n',stamp,'NoGoStim');
            peck(1) = peck(1) + 1;
            if strcmp(get(TimerFeeder, 'Running'), 'on')
                stop(TimerFeeder);
            end
            fprintf(1,'Total # of pocks since begining: %d\n', peck(1));
            fprintf('NoGo Stim -> No Reward\n')

        end
    end
else
    if (Past_inval(1) == 1)
        fprintf(1, 'End of Pocking\n');
    end
end

%% respond with output signal given input for the Feeding Bucket
if (inval(2) == 1) && (Past_inval(2) == 0)
    fprintf(fid_out6,'%.2f\t%s\n',stamp,'StartFeed');
    fprintf(1,'Hyena by the feeding bucket\n');
elseif (inval(2) == 0) && (Past_inval(2) == 1)
    fprintf(fid_out6,'%.2f\t%s\n',stamp,'StopFeed');
end

%% update the past status of IR sensors, so that we can go on
    Past_inval(2) = inval(2);
    Past_inval(1) = Pocking;

end

            

