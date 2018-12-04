function [IndicesReUsed,OddsRatioWH, OddsRatioW, OddsRatioPH, OddsRatioP,ph] = RunningOddsVoice(Interruption, BinStim, Verbose,Fig,wind) % here I added wind as the size of your window
%% Graphs the running mean in sets of wind(=4 by default) for Re and NoRe Stimuli
% Interruption is a binary vector indicating interruption of each stimulus
% BinStim is a binary vector indicating  the stim type played. For BinStim,
% 1 = Re and 0 = NoRe

if nargin<5
    wind = 4; %this line puts the window size as 4  by default if nothing is precised
end
if nargin<4
    Fig = 0;
end

if nargin<3
    Verbose = 0;
end

PaperGraph=1; %set this to 1 if you want the printed version of the graph

%% Create loop that iterates through vector and creates running value of odds ratio
NPeck = length(Interruption);  
TotalRe = sum(BinStim);
RepeckoddW = zeros(length(wind:wind:max(TotalRe)),1);
RepeckoddWH = zeros(length(wind:wind:max(TotalRe)),1);
%NoGopeckodd = zeros(length(wind:wind:max(TotalGo)),1);
OddsRatioW = zeros(length(wind:wind:max(TotalRe)),1);
OddsRatioWH = zeros(length(wind:wind:max(TotalRe)),1);
OddsRatioP = zeros(length(wind:wind:max(TotalRe)),1);
OddsRatioPH = zeros(length(wind:wind:max(TotalRe)),1);
%SuccErr = zeros(length(wind:wind:max(TotalGo)),1);
Vect = wind:wind:TotalRe(1);
IndicesRe=find(BinStim);

jj=1;
for ii = 1:length(Vect)
    indexRE = IndicesRe(Vect(ii));
    
    %Calculating the harmonic n
    InvBin = ~BinStim;
    NNRe = sum(InvBin(jj:indexRE)); % number of NoRe stim
    windH=1/(1/wind + 1/NNRe);
    
    % Odds of interrupting a Re Stim
    ReInt = Interruption(jj:indexRE) .* BinStim(jj:indexRE);
    PRe = sum(ReInt)/sum(BinStim(jj:indexRE));
    NReInt = sum(ReInt);
    
    % Wilson corrrection
    ProbaReIntW = (PRe+1.96^2/(2*wind))/(1+1.96^2/wind); %Calculate the center of the Wilson interval for that probability with alpha=5% (so z=1.96) (Wikipedia)
    OddsReIntW = ProbaReIntW/(1-ProbaReIntW);
    RepeckoddW(ii) = OddsReIntW;
    ProbaReIntWH = (PRe+1.96^2/(2*windH))/(1+1.96^2/windH); %Calculate the center of the Wilson interval for that probability with alpha=5% (so z=1.96) and n harmonique instead of real n (Wikipedia)
    OddsReIntWH = ProbaReIntWH/(1-ProbaReIntWH);
    RepeckoddWH(ii) = OddsReIntWH;
    
    %Parzen correction
    if (NReInt == 0)
        plow = 0;
        phigh = 1-power(0.5, 1/wind);
        plowHarm = 0;
        phighHarm = 1-power(0.5, 1/windH);
    elseif (NReInt == wind)
        plow = power(0.5, 1/wind);
        phigh = 1;
        plowHarm = power(0.5, 1/windH);
        phighHarm = 1;
    else
        plow = betainv(0.5, NReInt, wind-NReInt+1);
        phigh = betainv(0.5, NReInt+1, wind-NReInt);
        plowHarm = betainv(0.5, NReInt*windH/wind, (wind-NReInt)*windH/wind+1);
        phighHarm = betainv(0.5, NReInt*windH/wind+1, (wind-NReInt)*windH/wind);
    end
    ProbaReIntP = (plow+phigh)./2;
    ProbaReIntPH = (plowHarm + phighHarm)./2;
    OddsReIntP = ProbaReIntP./(1-ProbaReIntP);
    OddsReIntPH = ProbaReIntPH./(1-ProbaReIntPH);
    
    %Odds of interrupting a NoRe stim
    NoReInt = Interruption(jj:indexRE) .* InvBin(jj:indexRE);
    NNoReInt = sum(NoReInt);
    PNRe = NNoReInt/sum(InvBin(jj:indexRE));
    
    %Wilson correction
    ProbaNoReIntW = (PNRe+1.96^2/(2*NNRe))/(1+1.96^2/NNRe); %Calculate the center of the Wilson interval for that probability with alpha=5% (so z=1.96)
    ProbaNoReIntWH = (PNRe+1.96^2/(2*windH))/(1+1.96^2/windH); %Calculate the center of the Wilson interval for that probability with alpha=5% (so z=1.96) and n harmonique instead of real n
    OddsNoReIntWH = ProbaNoReIntWH/(1-ProbaNoReIntWH);
    OddsNoReIntW = ProbaNoReIntW/(1-ProbaNoReIntW);
    
    %Parzen correction
    if (NNoReInt == 0)
        plow = 0;
        phigh = 1-power(0.5, 1/NNRe);
        plowHarm = 0;
        phighHarm = 1-power(0.5, 1/windH);
    elseif (NNoReInt == NNRe)
        plow = power(0.5, 1/NNRe);
        phigh = 1;
        plowHarm = power(0.5, 1/windH);
        phighHarm = 1;
    else
        plow = betainv(0.5, NNoReInt, NNRe-NNoReInt+1);
        phigh = betainv(0.5, NNoReInt+1, NNRe-NNoReInt);
        plowHarm = betainv(0.5, NNoReInt*windH/NNRe, (NNRe-NNoReInt)*windH/NNRe+1);
        phighHarm = betainv(0.5, NNoReInt*windH/NNRe+1, (NNRe-NNoReInt)*windH/NNRe);
    end
    ProbaNoReIntP = (plow+phigh)./2;
    ProbaNoReIntPH = (plowHarm + phighHarm)./2;
    OddsNoReIntP = ProbaNoReIntP./(1-ProbaNoReIntP);
    OddsNoReIntPH = ProbaNoReIntPH./(1-ProbaNoReIntPH);
    
    %Calculating Odds ratio of interrupting
    OddsRatioWH(ii) = log2(OddsNoReIntWH/OddsReIntWH);
    OddsRatioW(ii) = log2(OddsNoReIntW/OddsReIntW);
    OddsRatioPH(ii) = log2(OddsNoReIntPH/OddsReIntPH);
    OddsRatioP(ii) = log2(OddsNoReIntP/OddsReIntP);
    %SuccErr(ii) = ProbaNoReInt - ProbaReInt;
    %NoRepeckodd(ii) = OddsNoReIntWH;
    
    
    jj = indexRE + 1;
end
Unused = NPeck-IndicesRe(Vect(end));
if Verbose
    fprintf(1, '***** The %d last pecks are disregarded to construct the graph*****\n', Unused);
end
IndicesReUsed = IndicesRe(Vect);


%% Graph data
if Fig
    Title = 'Odds Ratio ';

    d = input('Enter figure number: ');

    x1=IndicesRe(Vect);
    y1=OddsRatioWH(1:length(Vect));
    y3=OddsRatioW(1:length(Vect));
    y5=OddsRatioPH(1:length(Vect));
    y7=OddsRatioP(1:length(Vect));

    figure(d)
    YTickLabels= ['/12';' /8';' /4'; '0  '; ' x4'; ' x8'; 'x12'];
    YTickLabelslong= ['/16'; '/12';' /8';' /4'; '0  '; ' x4'; ' x8'; 'x12'; 'x16'];
    subplot(2,1,1)
    ph = plot(x1,y3,'b*-',x1,polyval(polyfit(x1,y3,1),x1),'r-');
    axis([-30 sum(NPeck) -6 6])
    set(get(ph(1),'Parent'), 'YTickLabel', YTickLabels);
    %vline([0 S1T1+S1T2+S1T3 S1T1+S1T2+S1T3+2], {'k','k','k'}, {'Day1', '','Day2'});
    hline(0, ':k');
    title(strcat(Title, ' Wilson correction'));

    subplot(2,1,2)
    ph = plot(x1,y1,'b*-',x1,polyval(polyfit(x1,y1,1),x1),'r-');
    axis([-30 sum(NPeck) -6 6])
    set(get(ph(1),'Parent'), 'YTickLabel', YTickLabels);
    %vline([0 S1T1+S1T2+S1T3 S1T1+S1T2+S1T3+2], {'k','k','k'}, {'Day1', '','Day2'});
    hline(0, ':k');
    title(strcat(Title, ' Wilson harmonic correction'));

    figure(d+1)
    subplot(2,1,1)
    ph = plot(x1,y7,'b*-',x1,polyval(polyfit(x1,y7,1),x1),'r-');
    axis([-30 sum(NPeck) -8 8])
    set(get(ph(1),'Parent'), 'YTickLabel', YTickLabelslong);
    %vline([0 S1T1+S1T2+S1T3 S1T1+S1T2+S1T3+2], {'k','k','k'}, {'Day1', '','Day2'});
    hline(0, ':k');
    title(strcat(Title, ' Parzten correction'));

    subplot(2,1,2)
    ph = plot(x1,y5,'b*-',x1,polyval(polyfit(x1,y5,1),x1),'r-');
    axis([-30 sum(NPeck) -8 8])
    set(get(ph(1),'Parent'), 'YTickLabel', YTickLabelslong);
    %vline([0 S1T1+S1T2+S1T3 S1T1+S1T2+S1T3+2], {'k','k','k'}, {'Day1', '','Day2'});
    hline(0, ':k');
    title(strcat(Title, ' Parzten harmonic correction'));

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
    