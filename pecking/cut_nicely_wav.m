function [Y_out] = cut_nicely_wav(sound_in,samprate, Win)
Fig=0;
Thresh_increment=0.10;
need_cut=1;
while need_cut
    Thresh = Thresh_increment*std(sound_in); %silence is defined as 10% of average intensity calculated above
    yy = 1;
    MinSpace = ceil(0.01*samprate);% calls have to be spaced by at least 10ms to be separated. 10ms tail is added after the end sensus stricto of each sound and before the begining
    PotentialCuts = zeros(0); %Initialize the matrix that will contain start and end indices of silence slots
    while (yy>0) && (yy<length(sound_in))
        if abs(sound_in(yy))<Thresh
            Beg = yy;
            while abs(sound_in(yy))<Thresh && (yy<length(sound_in))
                yy = yy + 1;
            end
            End = yy;
            if End-Beg>(MinSpace)
                PotentialCuts = [PotentialCuts [Beg ; End]];
            end
        end
        yy = yy + 1;
    end
    [r,c]=size(PotentialCuts);
    on=ones(size(sound_in));
    if c~=0
        for cc=1:c
            on((PotentialCuts(1,cc)):1:(PotentialCuts(2,cc)))=0;% indicate zones of silences (0) and zones around calls that should be kept (60ms after the end and 10ms before the begining)
        end
    end
    on=on*0.8;
    if Fig
        figure(1)
        plot(on, '-r')
        hold on
        plot(sound_in,'-b')
        hold off
        %pause(1)
    end
    if isempty(PotentialCuts)
        % Increase threshold
        fprintf('Increasing threshold no potential cuts available\n')
        Thresh_increment = Thresh_increment + 0.05;
    else
        PotentialCutsMid = round([sum(PotentialCuts,1)/2 ; length(sound_in)-sum(PotentialCuts,1)/2]); % First row from start, second row, from end
        if Fig
            figure(1)
            for pp=1:size(PotentialCutsMid,2)
                hold on
                vline(PotentialCutsMid(1,pp))
            end
            hold off
            %pause(1)
        end
        [PotentialCutsMin, PotentialCutsMinIndex] = min(PotentialCutsMid); %identify the smallest cuts
        % Trim each time in the front and the back whichever is the smallest until
        % the stim is of the right size
        on_out=ones(size(sound_in));
        while sum(on_out)>(Win*samprate)
            %find the smallest chunck to suppress
            [~,MinCutInd]=min(PotentialCutsMin);
            if PotentialCutsMinIndex(MinCutInd)==1 %the chunk is taken from the start of the stim
                on_out(1:PotentialCutsMid(1,MinCutInd))=0;
            elseif PotentialCutsMinIndex(MinCutInd)==2 %the chunk is taken from the end of the stim
                on_out(PotentialCutsMid(1,MinCutInd):end)=0;
            end
            if Fig
                figure(1)
                hold on
                vline(PotentialCutsMid(1,MinCutInd),'-k')
            end
            % Get rid of that potential cut, it's been used
            PotentialCutsMin(MinCutInd)=[];
            PotentialCutsMinIndex(MinCutInd)=[];
            PotentialCutsMid(:,MinCutInd)=[];
            if isempty(PotentialCutsMin)
                % Increase threshold and break
                fprintf('Increasing threshold no more potential cuts available\n')
                Thresh_increment = Thresh_increment + 0.05;
                break
            end
        end
        if sum(on_out)<=(Win*samprate)
            need_cut=0;
        end
    end
end
if Fig
    figure(1)
    hold on
    plot(on_out*0.8, '-g')
    hold off
end
on_out_ind=find(on_out);
Y_out = sound_in(on_out_ind(1):on_out_ind(end));
end



