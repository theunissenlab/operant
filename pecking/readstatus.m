function readstatus(obj,event)

global dio starttime AS

% Read from the DIO board
inval = getvalue(dio.line(13:15)); %note: I will need to modify this based on whatever lines are assigned to connect with...
% the pecking key triggers

stamp = clock;
stamp = etime(stamp, starttime);
fprintf('%d\t%d\t%d\t%d\n',inval(1),inval(2),inval(3),fix(stamp));
if inval(2)==1
    %play(AS);
end


end

            

