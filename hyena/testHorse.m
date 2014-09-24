dio = digitalio('mcc', 0);
hwlinein1=addline(dio,0,0,'out');
hwlineout=addline(dio,0:1,1,'in');

while 1
    s = input('Type q for quitting and t for triggering: ','s');
    if strcmp(s, 't')
        putvalue(dio.line(1),1);
        fprintf(1,'button pressed\n');
        inval = getvalue(dio.line(1))
        pause(0.3);
        putvalue(dio.line(1),0);
        fprintf(1,'button released\n');
        inval = getvalue(dio.line(1))
    elseif strcmp(s, 'q')
        fprintf(1,'button nothing\n');
        inval = getvalue(dio.line(1))
        break;
        
    else
        fprintf(1,'%s is unvalid key - type q or t\n', s);
    end
end
