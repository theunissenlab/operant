function PockingTest_shaping_finalstop(obj, event)

global Yend AS dio TimerFeeder fid_out1 fid_out2 fid_out3...
    fid_out4 fid_out5 fid_out6 TimerStop TimerStart Trial peck

AS = update(AS,Yend,1);
play(AS)
stoptime=clock;
fprintf(fid_out1,'The trial stopped at %d:%d:%d \n', stoptime(4), stoptime(5), fix(stoptime(6)));
stop(dio);
putvalue(dio.line(1),0);
delete(dio);
clear dio;
if ~isempty(TimerFeeder)
    if strcmp(get(TimerFeeder, 'Running'), 'on')
        stop(TimerFeeder);
    end
    delete(TimerFeeder);
    clear TimerFeeder;
end

if ~isempty(fid_out1)
    fclose(fid_out1);
end
if ~isempty(fid_out2)
    fclose(fid_out2);
end
if ~isempty(fid_out3)
    fclose(fid_out3);
end
if ~isempty(fid_out4)
    fclose(fid_out4);
end
if ~isempty(fid_out5)
    fclose(fid_out5);
end
if ~isempty(fid_out6)
    fclose(fid_out6);
end
fprintf(1, 'Total number of pocks: %d\nTotal number of feedings: %d\n', peck(1), peck(2));
if ~isempty(TimerStart) && strcmp(class(TimerStart), 'timer')
    if strcmp(get(TimerStart, 'Running'), 'on')
        stop(TimerStart);
    end
    delete(TimerStart);
    clear TimerStart;
end
if ~isempty(Trial)
    if ischar(Trial)
        fprintf('************End of Trial %s at %d:%d:%d************\n', Trial, stoptime(4), stoptime(5), fix(stoptime(6)));
    elseif isnumeric(Trial)
        fprintf('************End of Trial %d at %d:%d:%d************\n', (Trial-1), stoptime(4), stoptime(5), fix(stoptime(6)));
    end
else
    fprintf('*****************END OF EXPERIMENT************\n');
end
if ~isempty(TimerStop)
    if strcmp(get(TimerStop, 'Running'), 'on')
        stop(TimerStop);
    end
    delete(TimerStop);
    clear TimerStop;
end

clear global all
clear all
delete(timerfind);
end