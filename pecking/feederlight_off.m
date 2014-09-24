function feederlight_off(obj, event, dio)

global fid_out1 starttime
% Brings the feeder down
putvalue(dio.line(3),0);
putvalue(dio.line(8),0);
CurrTime = clock;
stamp = etime(CurrTime, starttime);
fprintf(fid_out1,'Feeder was down at %d:%d:%d or %.2f sec after the begining of experiment \n', CurrTime(4), CurrTime(5), fix(CurrTime(6)), stamp);
disp('***The feeder is down!****\n');
end
