function plot_PeckingTest_actuogram(StimTypeRe1_NoRe0,Interruption,VocalizationMaxNumUses)
% StimTypeRe1_NoRe0: A logic vector (1*Nstims) indicating if the stim is a Rewarded (1) or Non
% Rewarded stim (0)

% Interruption: a logic vector (1*Nstims) indicating if the stim was interrupted (1) or
% not (0)

% VocalizationMaxNumUses: a vector of size (1*Nstims) indicating the number
% of time the stimulu was heard since the begining of the experiment


if nargin<3
    VocalizationMaxNumUses = [];
end

figure()
set(gcf,'Visible','on')
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
set(gcf, 'PaperUnits','inches','PaperSize',[4 3]);
Colorcode = get(groot,'DefaultAxesColorOrder');
NStims = length(StimTypeRe1_NoRe0);

Color= StimTypeRe1_NoRe0* Colorcode(3,:);
Ind_local3 = find(VocalizationMaxNumUses==1);
Ind_local3Rest = setdiff(1:NStims, Ind_local3);
hold off

yyaxis left
sc=scatter(Ind_local3Rest, Interruption(Ind_local3Rest)*1.2, 20, Color(Ind_local3Rest,:), 'filled');
hold on
if isempty(VocalizationMaxNumUses)
    sc=scatter(Ind_local3, Interruption(Ind_local3)*1.2, 20, Color(Ind_local3,:), 'filled');
else
    sc=scatter(Ind_local3, Interruption(Ind_local3)*1.2, 20, Color(Ind_local3,:), 'filled', 'MarkerEdgeColor','r');
    hold on
    sc=scatter(Ind_local3, ones(length(Ind_local3),1)*1.4, 20, 'r','v', 'filled');
end
hold on
ylim([-1 3])
Ticks = 0:ceil(NStims/10)*2:ceil(NStims/10)*10;
set(sc.Parent, 'XTick', Ticks, 'XTickLabel',Ticks)
get(get(sc,'Parent'),'XTickLabel');
set(gca, 'FontName', 'Arial', 'FontSize',9,'FontWeight','normal')
xlabel('Trial number', 'FontName', 'Arial', 'FontSize',9,'FontWeight','bold')
set(sc.Parent, 'YTick', [0 1.2], 'YTickLabel', {'No Int', 'Int'}, 'YColor', 'k')
get(get(sc,'Parent'),'YTick');
set(gca, 'FontName', 'Arial', 'FontSize',9,'FontWeight','bold')

yyaxis right
[~,OddsRatioP,pOddsRatioP,~,CenteredPecks] = RunningOddsInterrupt(Interruption, StimTypeRe1_NoRe0);
NumInd = length(CenteredPecks);
ph = plot(CenteredPecks,OddsRatioP(1:NumInd),'Color',Colorcode(1,:),'LineStyle','-','LineWidth',2,'Marker','none');
ylabel('Performance: Odds Ratio','FontName', 'Arial', 'FontSize',9,'FontWeight','bold');

% Setting up the Ylimit (you want to adapt this one for your data
ylim([-4 6]);
YTickLabelslong= [' /16';'  /4'; '1   '; '  x4'; ' x16'; ' x64'];
set(get(ph,'Parent'),'YTick',-4:2:6, 'YTickLabel', YTickLabelslong, 'YColor',Colorcode(1,:));
get(get(ph,'Parent'),'YTick');
set(gca, 'FontName', 'Arial', 'FontSize',9)
if sum(pOddsRatioP<0.05)
    hold on
    scatter(CenteredPecks(pOddsRatioP<0.05), OddsRatioP(pOddsRatioP<0.05), 50, 'r', 'd', 'filled');
    hold on
    scatter(CenteredPecks(pOddsRatioP>=0.05), OddsRatioP(pOddsRatioP>=0.05), 50, Colorcode(1,:), 'd', 'filled');
end
hold on
hline(0, ':k');

% Calulating and plotting the OR and pvalue for the whole test along the confidence interval for a random behavior
[OR,pO,CI] = OddsInterrupt(Interruption, StimTypeRe1_NoRe0);
hold on
XL = get(get(ph,'Parent'),'XLim');
ar1=area(0:XL(2),ones(XL(2)+1,1)*CI(1), 'LineStyle', ':', 'FaceColor', [0.8 0.8 0.8]);
alpha(ar1, 0.3);
hold on
ar2=area(0:XL(2),ones(XL(2)+1,1)*CI(2), 'LineStyle', ':', 'FaceColor', [0.8 0.8 0.8]);
alpha(ar2, 0.3);
if pO>0.05
    text(1, 4.5, sprintf('Not significant Odds ratio: %.2f', OR),'FontName', 'Arial', 'FontSize',8);
elseif pO<0.001
    pvalueprint = '0.001';
elseif pO<0.01
    pvalueprint = '0.01';
elseif pO<0.05
    pvalueprint = '0.05';
end
xlim(XL);
hold on
plot(XL(2),OR,'d','MarkerEdgeColor','r', 'MarkerFaceColor','r','MarkerSize',10)

Adding output details
text(1,5,sprintf('OR=%.2f p<%s', OR,pvalueprint), 'FontName','Arial','FontSize',7);
hold off