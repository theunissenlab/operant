function give_food(duration, dio, map);

if ~exist('dio', 'var');
    global dio;
    if ~exist('dio', 'var');
        return;
    end
end

if ~exist('map', 'var');
    map = dio_map();
end

