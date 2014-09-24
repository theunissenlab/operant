function feeder_up(dio)

global fid_out1 starttime

dio = digitalio('mcc', 0);
hwlinein1=addline(dio,0:7,0,'out');
hwlinein2=addline(dio,0:3,1,'out');
hwlineout=addline(dio,0:2,2,'in');
putvalue(dio.line(3),1);
CurrTime = clock;
stamp = etime(CurrTime, starttime);
fprintf(fid_out1,'Feeder was up at %d:%d:%d or %.2f sec after the begining of experiment \n', CurrTime(4), CurrTime(5), fix(CurrTime(6)), stamp);
disp('***The feeder is up!****\n');
end