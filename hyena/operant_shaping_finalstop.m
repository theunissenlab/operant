function operant_shaping_finalstop(obj, event)

global dio TimerFeeder FeederDown_Timer fid_out1 fid_out2 fid_out3...
    fid_out4 fid_out5 TimerStop TimerStart Trial peck

stoptime=clock;
if ~isempty(fid_out1)
    fprintf(fid_out1,'The trial stopped at %d:%d:%d \n', stoptime(4), stoptime(5), fix(stoptime(6)));
    stop(dio);
    putvalue(dio.line(1:12),zeros(1,12));
    delete(dio);
    clear dio;
    if ~isempty(TimerFeeder)
        if strcmp(get(TimerFeeder, 'Running'), 'on')
            stop(TimerFeeder);
        end
        delete(TimerFeeder);
        clear TimerFeeder;
    end

    if ~isempty(FeederDown_Timer)
        if strcmp(get(FeederDown_Timer, 'Running'), 'on')
            stop(FeederDown_Timer);
        end
        delete(FeederDown_Timer);
        clear FeederDown_Timer;
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
    fprintf(1, 'Total number of pecks: %d\n', sum(peck(1:3)));
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
        fprintf('*****************END OF EXPERIMENT AFTER 7HOURS************\n');
    end
    if ~isempty(TimerStop)
        if strcmp(get(TimerStop, 'Running'), 'on')
            stop(TimerStop);
        end
        delete(TimerStop);
        clear TimerStop;
    end
else
    file_name = sprintf('LEARNINGTEST_%2d%2d%2d_shaping_ForcedEnd_parameters.txt', stoptime(4), stoptime(5),fix(stoptime(6)));
    fid_out = fopen(file_name, 'wt');
    fprintf(fid_out,'The experiment stopped after 7 hours at %d:%d:%d \n', stoptime(4), stoptime(5), fix(stoptime(6)));
    fprintf('*****************END OF EXPERIMENT AFTER 7HOURS************\n');
end
clear global all
clear all
delete(timerfind);
end