global dio TimerFeeder FeederDown_Timer fid_out1 fid_out2 fid_out3 fid_out4 fid_out5

stoptime=clock;
fprintf(fid_out1,'The trial stopped at %d:%d:%d \n', stoptime(4), stoptime(5), fix(stoptime(6)));
stop(dio);
putvalue(dio.line(1:12),zeros(1,12));
delete(dio);
stop(TimerFeeder);
delete(TimerFeeder);
stop(FeederDown_Timer);
delete(FeederDown_Timer);
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
if exist('fid_out5', 'var')
    fclose(fid_out5);
end
fprintf(1, 'Total number of pecks: %d\n', sum(peck(1:3)));