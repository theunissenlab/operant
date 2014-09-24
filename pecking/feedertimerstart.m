function feedertimerstart

global fid_out4 starttime
% Brings the feeder down
putvalue(dio.line(3),0);
CurrTime = clock;
stamp = etime(CurrTime, starttime);
fprintf(fid_out4, '%d\t%s\n',fix(stamp),'Down');
disp('***The feeder is down!****\n');
end