function horseFeeder_off(obj, event)
global starttime fid_out4 TrackFeederBucket
CurrTime = clock;
stamp = etime(CurrTime, starttime);
disp('***Not fast enough, the feeder stays off!****');
fprintf(fid_out4, '%d\t%s\n',fix(stamp),'off_too_slow');
stop(TrackFeederBucket)