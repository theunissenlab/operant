function feeder_up_choice(obj, event, dio, FeederDown_Timer)
global starttime fid_out4
% Brings the feeder up
putvalue(dio.line(3),1);
CurrTime = clock;
stamp = etime(CurrTime, starttime);
disp('***The feeder is up!****');
fprintf(fid_out4, '%d\t%s\n',fix(stamp),'Up');

if strcmp(get(FeederDown_Timer,'Running'),'on')
    stop(FeederDown_Timer);
end
start(FeederDown_Timer);

end
