function lme = plotSummary(quantVar, subj, useNum, probeInfo, exSubj, quantVarStyle, colAni)

    % remove nan days
    quantVec = quantVar(~isnan(quantVar(:)));
    uses = useNum(~isnan(quantVar(:)));
    subjVec = subj(~isnan(quantVar(:))); % Is this wrong?
    probesVec = cellfun(@(y) y{2}, cellfun(@(x) strsplit(x,' '), subjVec, 'uni', 0), 'uni', 0);
    probeSNUni = cellfun(@(x) num2str(x), probeInfo.serialNumber, 'uni', 0)';

    switch quantVarStyle 
        case 'count'    
            ylab = {'Recorded units'};
        case 'amp'    
            ylab = {'Unit median amplitude (uV)'};
        case 'rms'
            ylab = {'RMS (uV)'};
        case 'slope_count'
            ylab = {'% change of unit';  ' count (%/day)'};
            quantVec = 100*(10.^(quantVec)-1);
        case 'slope_amp'
            ylab = {'% change of amplitude (uV/day)'};
        case 'slope_rms'
            ylab = {'% change of RMS (uV/day)'};
    end

    % find pos of each probe
    probeRef = regexp(subjVec,' ','split');
    APpos = nan(1,numel(probeRef));
    MLpos = nan(1,numel(probeRef));
    for p = 1:numel(probeRef)
        probeIdx = strcmp(probeSNUni,probeRef{p}{2});
        subIdx = strcmp(probeInfo.implantedSubjects{probeIdx},probeRef{p}{1});
        APpos(p) = str2double(probeInfo.positionAP{probeIdx}{subIdx});
        MLpos(p) = str2double(probeInfo.positionML{probeIdx}{subIdx});
    end
    
    % Mixed effects linear models
    T = struct();
    T.quant = quantVec;
    T.probeID = probesVec;
    T.APpos = APpos';
    T.MLpos = abs(MLpos)';
    T.uses = uses;
    T = struct2table(T);
    fnames = T.Properties.VariableNames; 
    fnames(contains(fnames,'quant')) = [];
    fnames(contains(fnames,'probeID')) = [];
    formula = 'quant ~ 1+';
    for ff = 1:numel(fnames)
        formula = [formula fnames{ff} '+'];
    end
    formula = [formula '(1|probeID) + (uses-1|probeID)'];
    lme = fitlme(T,formula);
    
    figure;
    idx = find(lme.Coefficients.pValue<0.05);
    [~,sortidx] = sort(lme.Coefficients.pValue(idx),'ascend');
    idx = idx(sortidx);
    bar(1:numel(idx),lme.Coefficients.pValue(idx))
    set(gca,'Yscale','log')
    xticks(1:numel(idx))
    xticklabels(lme.CoefficientNames(idx))
    xtickangle(45)
    xlabel('coeff')
    ylabel('pvalue')
    
    
    %% Summary plots
    
    probesIdx = cell2mat(cellfun(@(x) find(strcmp(probeSNUni, x)), probesVec, 'uni' ,0));
    % colAnitmp = [colAniToInspect(~isnan(quantVar(:,1)),:); colAniToInspect(~isnan(quantVar(:,2)),:)];
    
    [~,idx] = sort(quantVec);
    x = 1:numel(quantVec);
    y = quantVec;
    figure('Position',[680   727   404   180]);
    ax(1) = subplot(121);
    hold all
    % patch([min(x) min(x) max(x) max(x)], [SteinmetzSlopes SteinmetzSlopes(end:-1:1)], ones(1,3)*0.9,  'EdgeColor','none')
    % scatter(x,y(idx),40*uses(idx),[0.5 0.5 0.5],'filled');
    % fullProbeIdx = find(contains(subjVec(idx),fullProbeSubj));
    for ff = 1:numel(x)
        scatter(x(ff),y(idx(ff)),20,'MarkerEdgeColor',[.5 .5 .5], ...
            'MarkerFaceColor',[.5 .5 .5], ...
            'Marker','o');
    end
    % scatter(x(fullProbeIdx),y(idx(fullProbeIdx)),40*uses(idx(fullProbeIdx)),colAnitmp(idx(fullProbeIdx),:),'filled');
    ylabel(ylab)
    xlabel('Experiment')
    ax(2) = subplot(122); 
    hold all
    % patch([0 0 10 10], [SteinmetzSlopes SteinmetzSlopes(end:-1:1)], ones(1,3)*0.9,  'EdgeColor','none')
    h = histogram(y(idx),linspace(min(y),max(y),20),'orientation','horizontal','EdgeColor','none','FaceColor',[.5 .5 .5]);
    linkaxes(ax,'y')
    
    % plot quant as a function of AP position
    figure('Position',[680   728   200   180]); hold all
    x = APpos;
    y = quantVec;
    % patch([min(x) min(x) max(x) max(x)], [SteinmetzSlopes SteinmetzSlopes(end:-1:1)], ones(1,3)*0.9,  'EdgeColor','none')
    for ff = 1:numel(x)
        scatter(x(ff),y(ff),20,'MarkerEdgeColor',[.5 .5 .5], ...
            'MarkerFaceColor',[.5 .5 .5], ...
            'Marker','o');
    end
    % plot example animal
    probeIdx = find(contains(subjVec,exSubj));
    scatter(x(probeIdx),y(probeIdx),20,'MarkerEdgeColor',colAni, ...
            'MarkerFaceColor',colAni, ...
            'Marker','o');
    plot(unique(x),lme.Coefficients.Estimate(1) + ...
        lme.Coefficients.Estimate(contains(lme.CoefficientNames,'uses'))*nanmean(uses) + ...
        lme.Coefficients.Estimate(contains(lme.CoefficientNames,'MLpos'))*nanmean(MLpos) + ...
        lme.Coefficients.Estimate(contains(lme.CoefficientNames,'APpos'))*unique(x),'k','LineWidth',2)
    ylabel(ylab)
    xlabel('AP position')
    % ylim([-30 10])
    offsetAxes
    
    % Plot quant as a function of uses
    figure('Position',[680   728   200   180]); hold all
    x = uses;
    y = quantVec;
    probesVecUni = unique(probesVec);
    for pp = 1:numel(probesVecUni)
        probeIdx = find(strcmp(probesVec,probesVecUni{pp}));
        [m,sortIdx] = sort(uses(probeIdx));
        probeIdx = probeIdx(sortIdx);
        probeRef = find(strcmp(probeSNUni,probesVecUni{pp}));
        scatter(x(probeIdx),y(probeIdx),20,'MarkerEdgeColor',[.5 .5 .5], ...
            'MarkerFaceColor',[.5 .5 .5], ...
            'Marker','o');
        plot(x(probeIdx),y(probeIdx),'color',[.5 .5 .5]);
    end
    % plot example animal
    probeIdx = contains(subjVec,exSubj);
    probeRef = find(strcmp(probeSNUni,probesVecUni{pp}));
    scatter(x(probeIdx),y(probeIdx),20,'MarkerEdgeColor',colAni, ...
            'MarkerFaceColor',colAni, ...
            'Marker','o');
    plot(unique(x),lme.Coefficients.Estimate(1) + ...
        lme.Coefficients.Estimate(contains(lme.CoefficientNames,'APpos'))*nanmean(APpos) + ...
        lme.Coefficients.Estimate(contains(lme.CoefficientNames,'MLpos'))*nanmean(MLpos) + ...
        lme.Coefficients.Estimate(contains(lme.CoefficientNames,'uses'))*unique(x),'k','LineWidth',2)
    ylabel(ylab)
    xlabel('Probe uses')
    xticks(1:2:7)
    % ylim([-30 10])
    offsetAxes