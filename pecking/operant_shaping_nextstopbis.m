function operant_shaping_nextstopbis(obj, event)

global dio TimerFeeder FeederDown_Timer fid_out1 fid_out2 fid_out3...
    fid_out4 TimerStop Trial peck

stoptime=clock;
fprintf(fid_out1,'The trial stopped at %d:%d:%d \n', stoptime(4), stoptime(5), fix(stoptime(6)));
stop(dio);
putvalue(dio.line(1:12),zeros(1,12));
delete(dio);
clear dio;
stop(TimerFeeder);
delete(TimerFeeder);
clear TimerFeeder;
stop(FeederDown_Timer);
delete(FeederDown_Timer);
clear FeederDown_Timer;
if exist('fid_out1', 'var')
    fclose(fid_out1);
end
if exist('fid_out2', 'var')
    fclose(fid_out2);
end
if exist('fid_out3', 'var')
    fclose(fid_out3);
end
if exist('fid_out4', 'var')
    fclose(fid_out4);
end

fprintf(1, 'Total number of pecks: %d\n', sum(peck(1:3)));
if ischar(Trial)
    fprintf('************End of Trial %s at %d:%d:%d************\n', Trial, stoptime(4), stoptime(5), fix(stoptime(6)));
elseif isnumeric(Trial)
    fprintf('************End of Trial %d at %d:%d:%d************\n', (Trial-1), stoptime(4), stoptime(5), fix(stoptime(6)));
end
stop(TimerStop);
delete(TimerStop);
clear TimerStop;
end