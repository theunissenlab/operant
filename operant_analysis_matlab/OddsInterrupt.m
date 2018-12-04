function [OddsRatioP, pOddsRatioP , ci_OddsRatioP] = OddsInterrupt(Interruption, BinStim, p_CI, FIG) 

if nargin<3
    p_CI=0.05; % 5% confidence interval
end

if nargin<4
    FIG=0;
end

InvBin = ~BinStim;
NNoRe = sum(InvBin); % number of NoRe stim
NRe = sum(BinStim); % number of Re stim
ReInt = Interruption .* BinStim;
NReInt = sum(ReInt); % number of Re stims interrupted
NoReInt = Interruption.*InvBin;
NNoReInt = sum(NoReInt); % number of No Re stims interrupted


%% Calculating the observed Odds ratio
% Parzen correction on the Odds of interrupting a Re Stim
if (NReInt == 0)
    plow = 0;
    phigh = 1-power(0.5, 1/NRe);
elseif (NReInt == NRe)
    plow = power(0.5, 1/NRe);
    phigh = 1;
else
    plow = betainv(0.5, NReInt, NRe-NReInt+1);
    phigh = betainv(0.5, NReInt+1, NRe-NReInt);
end
ProbaReIntP = (plow+phigh)./2;
OddsReIntP = ProbaReIntP./(1-ProbaReIntP);

% Parzen correction on the odds of interrupting a NoRe stim
if (NNoReInt == 0)
    plow = 0;
    phigh = 1-power(0.5, 1/NNoRe);
elseif (NNoReInt == NNoRe)
    plow = power(0.5, 1/NNoRe);
    phigh = 1;
else
    plow = betainv(0.5, NNoReInt, NNoRe-NNoReInt+1);
    phigh = betainv(0.5, NNoReInt+1, NNoRe-NNoReInt);
end
ProbaNoReIntP = (plow+phigh)./2;
OddsNoReIntP = ProbaNoReIntP./(1-ProbaNoReIntP);

%Calculating Odds ratio of interrupting
OddsRatioP = log2(OddsNoReIntP/OddsReIntP);


%% Calculating the expected confidence interval if the interruption was random (binomial distribution with p=0.5
% given the number of events and the number of Re and NoRe stimuli
% Loop through all possible combinations of number of NoRe interuption and
% of number of Re Interruption
OddsRatioP_list = nan(NRe*NNoRe,1); % list of all possible values of odds ratio
pOddsRatioP_list = nan(NRe*NNoRe,1); %probability of obtaining this odds ratio
nn=0;
for rr=1:(NRe+1)
    ri=rr-1;
    for nrr=1:(NNoRe+1)
        nri = nrr-1;
        % Parzen correction on the Odds of interrupting a Re Stim
        if (ri == 0)
            plow = 0;
            phigh = 1-power(0.5, 1/NRe);
        elseif (ri == NRe)
            plow = power(0.5, 1/NRe);
            phigh = 1;
        else
            plow = betainv(0.5, ri, NRe-ri+1);
            phigh = betainv(0.5, ri+1, NRe-ri);
        end
        ProbaReIntP = (plow+phigh)./2;
        OddsReIntP = ProbaReIntP./(1-ProbaReIntP);
        
        %Parzen correction on the odds of interrupting a NoRe stim
        if (nri == 0)
            plow = 0;
            phigh = 1-power(0.5, 1/NNoRe);
        elseif (nri == NNoRe)
            plow = power(0.5, 1/NNoRe);
            phigh = 1;
        else
            plow = betainv(0.5, nri, NNoRe-nri+1);
            phigh = betainv(0.5, nri+1, NNoRe-nri);
        end
        ProbaNoReIntP = (plow+phigh)./2;
        OddsNoReIntP = ProbaNoReIntP./(1-ProbaNoReIntP);
        
        %Calculating Odds ratio of interrupting
        nn=nn+1;
        OddsRatioP_list(nn) = log2(OddsNoReIntP/OddsReIntP);
        
        % Calculating the probability of this odds ratio assuming random bernouilli
        % probability distribution
        pOddsRatioP_list(nn) = binopdf(ri, NRe, 0.5) * binopdf(nri, NNoRe, 0.5);
    end
end

% Get the cumulative distribution function of values of Odds ratio
[OddsRatioP_ord, Ind] = sort(OddsRatioP_list);
CDF_OddsRatioP = cumsum(pOddsRatioP_list(Ind));
pOddsRatioP = 1-CDF_OddsRatioP(find(OddsRatioP_ord<=OddsRatioP, 1,'last'));

% Calculating the confidence interval between p=0.05 and p=0.95
ci_OddsRatioP=nan(length(p_CI),2);
for pp=1:length(p_CI)
    % finding the closest value to p=p_CI on the lower side
    Low=find(CDF_OddsRatioP<p_CI(pp), 1, 'last');
    % finding the closest value to p=p_CI on the higher side
    High=find(CDF_OddsRatioP>p_CI(pp), 1, 'first');
    if isempty(Low)
        Low=High;
        High = find(CDF_OddsRatioP>p_CI(pp));
        High = High(2);
    end
    if Low==High
        ci_OddsRatioP(pp,1) = OddsRatioP_ord(Low);
    else % Let's do a linear interpolation
        Slope = (CDF_OddsRatioP(High) - CDF_OddsRatioP(Low)) / (OddsRatioP_ord(High) - OddsRatioP_ord(Low));
        Ord = CDF_OddsRatioP(High) - Slope*OddsRatioP_ord(High);
        ci_OddsRatioP(pp,1) = (p_CI(pp) - Ord)/Slope;
    end

    % finding the closest value to p=1-p_CI on the lower side
    Low=find(CDF_OddsRatioP<(1-p_CI(pp)), 1, 'last');
    % finding the closest value to p=0.05 on the higher side
    High=find(CDF_OddsRatioP>(1-p_CI(pp)), 1, 'first');
    if isempty(High)
        High=Low;
        Low = find(CDF_OddsRatioP<(1-p_CI(pp)));
        Low = Low(end-1);
    end
    if Low==High
        ci_OddsRatioP(pp,2) = OddsRatioP_ord(Low);
    else % Let's do a linear interpolation
        Slope = (CDF_OddsRatioP(High) - CDF_OddsRatioP(Low)) / (OddsRatioP_ord(High) - OddsRatioP_ord(Low));
        Ord = CDF_OddsRatioP(High) - Slope*OddsRatioP_ord(High);
        ci_OddsRatioP(pp,2) = (1-p_CI(pp) - Ord)/Slope;
    end
end
    
if FIG
    figure()
    plot(OddsRatioP_ord, CDF_OddsRatioP, 'k-', 'LineWidth',2)
    ylabel('Cumulative probability')
    xlabel('Odds Ratio')
    hold on
    line([OddsRatioP OddsRatioP], [0 1],  'color','r','LineStyle','-','LineWidth',2)
    hold on
    line([ci_OddsRatioP(1) ci_OddsRatioP(1)], [0 1], 'color','r','LineStyle',':','LineWidth',2)
    hold on
    line([ci_OddsRatioP(2) ci_OddsRatioP(2)], [0 1], 'color','r','LineStyle',':','LineWidth',2)
    text(OddsRatioP, 0.8, sprintf('Odds Ratio Observed = %.1f\nProbability = %.2f', OddsRatioP, pOddsRatioP));
    hold off
end
end