function checkFB(obj, event, dio)

global starttime fid_out4 peck TFB once TrackFeederBucket TimerFeeder

TFB = TFB + getvalue(dio.line(2));%line2 is the feeding bucket IR sensor

% Brings the feeder on only if the hyena already arrived
if TFB>0 && once==0
    putvalue(dio.line(1),1);
    pause(0.2)
    putvalue(dio.line(1),0);
    CurrTime = clock;
    stamp = etime(CurrTime, starttime);
    disp('***The feeder is on!****');
    fprintf(fid_out4, '%d\t%s\n',fix(stamp),'On');
    peck(2)=peck(2)+1;
    fprintf(1,'Total # of feedings since begining: %d\n', peck(2));
    once=1;
    stop(TrackFeederBucket)
    stop(TimerFeeder)
end
end