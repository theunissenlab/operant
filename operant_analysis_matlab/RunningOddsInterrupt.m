function [IndicesReUsed,OddsRatioP, pOddsRatioP, ci_OddsRatioP, CenteredPeck, ph] = RunningOddsInterrupt(Interruption, BinStim, Cum, Verbose,Fig,wind) % here I added wind as the size of your window
%% Graphs the running mean in sets of wind(=4 by default) for Re and NoRe Stimuli
% Interruption is a binary vector indicating interruption of each stimulus
% BinStim is a binary vector indicating  the stim type played. For BinStim,
% 1 = Re and 0 = NoRe

if nargin<6
    wind = 4; %this line puts the window size as 4  by default if nothing is precised
end
if nargin<5
    Fig = 0;
end

if nargin<4
    Verbose = 0;
end

if nargin<3
    Cum = 0;
end

PaperGraph=1; %set this to 1 if you want the printed version of the graph

%% Create loop that iterates through vector and creates running value of odds ratio
NPeck = length(Interruption);  
TotalRe = sum(BinStim);
OddsRatioP = zeros(length(wind:wind:max(TotalRe)),1);
pOddsRatioP = zeros(length(wind:wind:max(TotalRe)),1);
ci_OddsRatioP = zeros(length(wind:wind:max(TotalRe)),2);
Vect = wind:wind:TotalRe(1);
IndicesRe=find(BinStim);
IndicesReFirst = [1 ;IndicesRe(Vect)];
IndicesReLast = IndicesRe(Vect);

if Cum
    parfor ii = 1:length(Vect)
        [OddsRatioP(ii), pOddsRatioP(ii) , ci_OddsRatioP(ii,:)] = OddsInterrupt(Interruption(1:IndicesReLast(ii)), BinStim(1:IndicesReLast(ii)), Fig); 
    end
else
    parfor ii = 1:length(Vect)
        [OddsRatioP(ii), pOddsRatioP(ii) , ci_OddsRatioP(ii,:)] = OddsInterrupt(Interruption(IndicesReFirst(ii):IndicesReLast(ii)), BinStim(IndicesReFirst(ii):IndicesReLast(ii)), Fig); 
     end
end

Unused = NPeck-IndicesRe(Vect(end));
if Verbose
    fprintf(1, '***** The %d last pecks are disregarded to construct the graph*****\n', Unused);
end
IndicesReUsed = IndicesRe(Vect);
CenteredPeck = (IndicesReUsed - [0; IndicesReUsed(1:end-1)])/2 + [0; IndicesReUsed(1:end-1)];



%% Graph data
if Fig
    Title = 'Odds Ratio ';

    d = input('Enter figure number: ');

    x1=IndicesRe(Vect);
    y7=OddsRatioP(1:length(Vect));

    figure(d)
    YTickLabelslong= ['/32'; '/16';' /8';' /4';' /2'; '0  ';' x2';  ' x4'; ' x8'; 'x16'; 'x32'];
    
    ph = plot(x1,y7,'b*-',x1,polyval(polyfit(x1,y7,1),x1),'r-');
    axis([-30 sum(NPeck) -8 8])
    set(get(ph(1),'Parent'), 'YTick',[-5:1:5],'YTickLabel', YTickLabelslong);
    %vline([0 S1T1+S1T2+S1T3 S1T1+S1T2+S1T3+2], {'k','k','k'}, {'Day1', '','Day2'});
    hline(0, ':k');
    title(strcat(Title, ' Parzten correction'));

    %% Science graph
    if PaperGraph==1 && strcmp(Birdname, 'LblWhi0938')
        figure(d+2)
        ph = plot(x1,y7,'b*-',x1,polyval(polyfit(x1,y7,1),x1),'r-');
        axis([-30 sum(NPeck) -4 6])
        set(get(ph(1),'Parent'), 'YTickLabel', [' /8';' /4'; '0  '; ' x4'; ' x8'; 'x12']);
        vline([0 S1T1+S1T2+S1T3 S1T1+S1T2+S1T3+2], {'k','k','k'}, {'Day1', '','Day2'});
        hline(0, ':k');
        title(strcat(Title, ' Parzten correction'));
    elseif PaperGraph==1 && strcmp(Birdname, 'GraRas1600')
        figure(d+2)
        ph = plot(x1,y7,'b*-',x1,polyval(polyfit(x1,y7,1),x1),'r-');
        axis([0 sum(NPeck) -4 8])
        set(get(ph(1),'Parent'), 'YTickLabel', [' /8';' /4'; '0  '; ' x4'; ' x8'; 'x12'; 'x16']);
        vline([0 S1T1+S1T2+S1T3 S1T1+S1T2+S1T3+2], {'k','k','k'}, {'Day1', '','Day2'});
        hline(0, ':k');
        title(strcat(Title, ' Parzten correction'));
    end
    % Export properties for the figures of Science Paper (Empathy):
    % resize the export figure at 6 15 for the results of LblWhi3908
    % and 5.5 21.5 for the results of GraRas1600
    % Lines with a minimum of 1 point
    % font type= Helvetica, font size = 10.
else
    ph=[];
end
    