function operant_checklist()

dio = digitalio('mcc', 0);
hwlinein1=addline(dio,0:7,0,'out');
hwlinein2=addline(dio,0:3,1,'out');
hwlineout=addline(dio,0:2,2,'in');

map = dio_map();

fprintf('Running through initialization checklist.\n');
% Turn on the main light
fprintf('Checking the main light\n');
putvalue(dio.line(map.main), 1);

% Flash the key lights
fprintf('Checking the key lights\n');
for ii = 1: 5;
putvalue(dio.line(map.left), 1);
putvalue(dio.line(map.center), 1);
putvalue(dio.line(map.right), 1);
pause(0.1);
putvalue(dio.line(map.left), 0);
putvalue(dio.line(map.center), 0);
putvalue(dio.line(map.right), 0);
pause(0.1);
end

fprintf('Checking the center key light\n');
for ii = 1: 5;
putvalue(dio.line(map.center), 1);
pause(0.1);
putvalue(dio.line(map.center), 0);
pause(0.1);
end

fprintf('Checking feeder\n');
putvalue(dio.line(map.feeder), 1);
pause(0.5);
putvalue(dio.line(map.feeder), 0);

fprintf('Checking pecking input. Please gently press the center pecking key.\n');
set(dio, 'TimerFcn', @key_callback);
set(dio, 'TimerPeriod', 0.1);

fprintf('Please press it again.\n');
pause(1.0);

fprintf('Please press it once more.\n');
pause(1.0);

fprintf('Checking that feeder does not trigger key press\n');
for ii = 1: 5;
putvalue(dio.line(map.feeder), 1);
pause(0.5);
putvalue(dio.line(map.feeder), 0);
pause(0.5);
end

fprintf('Checklist completed\n');
stop(dio);
iolines = fieldnames(map);
for ii = 1: length(iolines);
putvalue(dio.line(map.(iolines{ii})), 0);
end
delete(dio);
clear dio

function key_callback(obj, event)

pressed = getvalue(dio.line(map.key));
if pressed
fprintf('Key pressed!');
% Play a 50 ms, 500 Hz tone to signal a key press
soundsc(sin(2 * pi * 500 * [1: 400]), 8000);
end

end




end