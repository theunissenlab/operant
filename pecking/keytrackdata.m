function [data, PosKey, PbKey] = keytrackdata(textfile)
%Import data into matlab
fid = fopen(textfile);
header = textscan(fid, '%s\t%s', 1);
data = textscan(fid, '%f%d');
fclose(fid);
PosKey = data{2} == 1;
SUMPosKey= sum(PosKey)
PbKey = data{2}>1;
SUMPbKey=sum(PbKey)
IndPb = find(data{2}>1);
TotalTimePb = 0;
for ii=1:SUMPbKey
    StartTimePb = data{1}(IndPb(ii)-1)
    EndTimePb = data{1}(IndPb(ii))
    LengthTimePb = EndTimePb-StartTimePb
    TotalTimePb = TotalTimePb + LengthTimePb;
end
if TotalTimePb>300
    fprintf('You should run an additional test, the bird behaviour was not recorded for %f secconds, and that is more than 5min\n', TotalTimePb);
elseif TotalTimePb>0
    fprintf('Note that the behavior of the bird was not recorded for %f seconds\n', TotalTimePb);
end
TrialDuration = length(data{1})/10;
if TrialDuration<1800
    fprintf('*****The test was not complete for some reason.\nIt only last for %f seconds instead of 1800 seconds*****\n', TrialDuration);
end
end