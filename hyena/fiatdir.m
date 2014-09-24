function out = fiatdir(dirname)
% Creates a directory even if its subdirectories do not exist.
% Testing SVN commit with this line SH 7-30-09

posslash = findstr(dirname,'\'); % Tyler modified / to \ 8/31/12
for i = 2:length(posslash)
    if isdir(dirname(1:posslash(i)))
    else
        toexec = strcat(['mkdir ''' dirname(1:posslash(i)) '''']); %Tyler modified to remove "[! mkdir" 8/31/12
        eval(toexec);
    end
end
if isdir(dirname)
else
    toexec = strcat(['mkdir ''' dirname '''']); %Tyler modified to remove "[! mkdir" 8/31/12
    eval(toexec);
end
out = 1;
