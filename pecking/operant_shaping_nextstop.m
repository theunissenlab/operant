function operant_shaping_nextstop(obj, event)

global dio TimerFeeder FeederDown_Timer fid_out1 fid_out2 fid_out3...
    fid_out4 fid_out5 TimerStop Trial peck

stoptime=clock;
fprintf(fid_out1,'The trial stopped at %d:%d:%d \n', stoptime(4), stoptime(5), fix(stoptime(6)));
stop(dio);
putvalue(dio.line(1:12),zeros(1,12));
delete(dio);
clear global dio;
stop(TimerFeeder);
delete(TimerFeeder);
clear global TimerFeeder;
stop(FeederDown_Timer);
delete(FeederDown_Timer);
clear global FeederDown_Timer;
if ~isempty(fid_out1)
    fclose(fid_out1);
    clear global fid_out1
end
if ~isempty(fid_out2)
    fclose(fid_out2);
    clear global fid_out2
end
if ~isempty(fid_out3)
    fclose(fid_out3);
    clear global fid_out3
end
if ~isempty(fid_out4)
    fclose(fid_out4);
    clear global fid_out4
end
if ~isempty(fid_out5)
    fclose(fid_out5);
    clear global fid_out5
end
fprintf(1, 'Total number of pecks: %d\n', sum(peck(1:3)));
if ischar(Trial)
    fprintf('************End of Trial %s at %d:%d:%d************\n', Trial, stoptime(4), stoptime(5), fix(stoptime(6)));
elseif isnumeric(Trial)
    fprintf('************End of Trial %d at %d:%d:%d************\n', (Trial-1), stoptime(4), stoptime(5), fix(stoptime(6)));
end
stop(TimerStop);
delete(TimerStop);
clear global TimerStop;
end