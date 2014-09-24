function horseFeeder_on(obj, event, dio, TFB)
global starttime fid_out4
% Brings the feeder on only if the hyena already arrived
if TFB>0
    putvalue(dio.line(1),1);
    pause(0.2)
    putvalue(dio.line(1),0);
    CurrTime = clock;
    stamp = etime(CurrTime, starttime);
    disp('***The feeder is on!****');
    fprintf(fid_out4, '%d\t%s\n',fix(stamp),'On');
else
    CurrTime = clock;
    stamp = etime(CurrTime, starttime);
    disp('***Not fast enough, the feeder stays off!****');
    fprintf(fid_out4, '%d\t%s\n',fix(stamp),'off too slow');
end
