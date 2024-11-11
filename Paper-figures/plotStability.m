function [valueMean, slopeMean, interceptMean, fullProbeSubj, subj, useNum] = plotStability(expInfoAll,subjectsToInspect,probeInfo,colAni,fullProbeScan,varType,paramplt)
    
    switch varType
        case 'count'
            qm = expInfoAll.unitCount';
            yRng = [1 4000];
            funcProbe = @sum;
            logYScale = 1;
            ylab = {'Recorded units'};
            fdecay = @(x) 10.^(x);
            fdecay_inv = @(x) log10(x);
        case 'amp'
            qm = expInfoAll.medAmp';
            yRng = [20 600];
            funcProbe = @nanmean;
            logYScale = 0;
            ylab = {'Unit median amplitude (uV)'};
            fdecay = @(x) x;
            fdecay_inv = @(x) x;
        case 'rms'
            qm = expInfoAll.medRMS';
            yRng = [1 40];
            funcProbe = @nanmean;
            logYScale = 0;
            ylab = {'RMS (uV)'};
            fdecay = @(x) x;
            fdecay_inv = @(x) x;
    end

    dlim = paramplt.dlim;
    pltIndivBank = paramplt.pltIndivBank;
    pltIndivProbe = paramplt.pltIndivProbe;
    pltAllProbes = paramplt.pltAllProbes;
    pltData = paramplt.pltData;
    pltFit = paramplt.pltFit;

    subjects = unique(expInfoAll.subject');
    probeSNUni = unique(expInfoAll.probeSN');
    
    recLocSlope = cell(1,1);
    b = cell(1,1);
    valueMean = nan(numel(subjectsToInspect),2);
    slopeMean = nan(numel(subjectsToInspect),2);
    interceptMean = nan(numel(subjectsToInspect),2);
    useNum = nan(numel(subjectsToInspect),2);
    fullProbeSubj = {};
    subj = {};
    days = cell2mat(expInfoAll.daysSinceImplant');
    daysSub = unique(days);
    qmProbe = nan(numel(daysSub),2,numel(subjectsToInspect));

    % figure
    figure('Position',[600 500 220 200]);
    hold all
    for ss = 1:numel(subjectsToInspect)
        subjectIdx = contains(expInfoAll.subject',subjectsToInspect(ss));
        probes = unique(expInfoAll.probeSN(subjectIdx)');
        colAniToInspect = colAni(ismember(subjects,subjectsToInspect(ss)),:);
        for pp = 1:numel(probes)
    
            % Check number of uses for this probe
            [~,useNum(ss,pp)] = find(contains(probeInfo.implantedSubjects{strcmp(probeSNUni,probes(pp))},subjectsToInspect{ss}));
    
            probeIdx = contains(expInfoAll.probeSN',probes(pp));
            subAndProbeIdx = find(subjectIdx & probeIdx);
            recLocGood = expInfoAll.recLocAll(subAndProbeIdx)';
            fullProbeScanSpec = cellfun(@(x) [subjectsToInspect{ss} '__' probes{pp} '__' x{1}], fullProbeScan, 'uni', 0);
    
            recLoc = unique(recLocGood);
            for rr = 1:numel(recLoc)
                recIdx = find(strcmp(expInfoAll.recLocAll',recLoc{rr}));
                if numel(unique(days(recIdx))) > 2 && max(qm(recIdx)) > 1
    
                    recLocSlope{ss,pp}{rr} = recLoc{rr};
    
                    % Compute the slope
                    X = [ones(numel(recIdx),1), days(recIdx)'];
                    tmp = qm(recIdx);
                    tmp(tmp == 0) = 0.1;
                    b{ss,pp}(rr,:) = (X\fdecay_inv(tmp'));
    
                    if pltIndivBank %&& any(contains(fullProbeScanSpec, recLoc{rr})) %&& pp == 1
    %                     colHack = [0.8157    0.2392    0.6039];
                        colHack = colAniToInspect;
                        if pltData; plot(days(recIdx), qm(recIdx),'color',[colHack .2]);
                            scatter(days(recIdx), qm(recIdx),5,colHack,'filled','MarkerEdgeAlpha',0.2,'MarkerFaceAlpha',0.2); end
                        if pltFit; plot(days(recIdx),fdecay(X*b{ss,pp}(rr,:)'), 'color',colHack,'LineWidth',1); end
                    end
                else
                    recLocSlope{ss,pp}{rr} = '';
                    b{ss,pp}(rr,:) = [nan;nan];
                end
            end
    
            if strcmp(varType, 'count')
                valueMean(ss,pp) = nanmean(qm(ismember(expInfoAll.recLocAll', recLocGood) & days < inf)); %min(days(ismember(recLocAll, recLocGood)))+7));
            else
                valueMean(ss,pp) = nanmean(qm(ismember(expInfoAll.recLocAll', recLocGood)));
            end
            slopeMean(ss,pp) = nanmean(b{ss,pp}(:,2));
            interceptMean(ss,pp) = nanmean(b{ss,pp}(:,1));
            subj{ss,pp} = [subjectsToInspect{ss} ' ' probes{pp}];
    
            for dd = 1:numel(daysSub)
                day = daysSub(dd);
                % Find recordings around that date
                surrDaysIdx = find(abs(days(subAndProbeIdx) - day) <= dlim);
                [~,daysOrd] = sort(abs(days(subAndProbeIdx(surrDaysIdx))-day), 'ascend');
                scanIdx = cell2mat(cellfun(@(x) ismember(recLocGood(surrDaysIdx(daysOrd)),x)', fullProbeScanSpec, 'uni', 0));
                if all(sum(scanIdx,1))
                    [~,scanIdx]=max(scanIdx,[],1);
                    qmProbe(dd,pp,ss) = funcProbe(qm(subAndProbeIdx(surrDaysIdx(daysOrd(scanIdx)))));
    
                    % sanity check
                    if ~isempty(scanIdx) && ~all(cell2mat(cellfun(@(x) ismember(x,recLocGood(surrDaysIdx((daysOrd(scanIdx)))))', fullProbeScanSpec, 'uni', 0)))
                        error('problem with scan')
                    end
                end
            end
    
            if pltIndivProbe
                % Show only one probe
                nanday = isnan(qmProbe(:,pp,ss));
                if pltData; plot(daysSub(~nanday),qmProbe(~nanday,pp,ss),'-','color',[colAniToInspect .2]); 
                scatter(daysSub(~nanday),qmProbe(~nanday,pp,ss),15,colAniToInspect,'filled'); end
                X = [ones(numel(daysSub(~nanday)),1), daysSub(~nanday)'];
                ball = (X\fdecay_inv(qmProbe(~nanday,pp,ss)));
                if pltFit plot(daysSub(~nanday), fdecay(X*ball), 'color',colAniToInspect,'LineWidth',1); end
                fullProbeSubj{end+1} = [subjectsToInspect{ss} ' ' probes{pp}];
                %             text(dayFullProbe(end), 10.^(X(end,:)*ball),fullProbeSubj{end},'color',colAniToInspect(ss,:))
            end
        end
    
        if pltAllProbes
            % Show two probes
            probesInUse = any(~isnan(qmProbe(:,:,ss)));
            qmAllProbes = nanmean(qmProbe(:,probesInUse,ss),2);
            nanday = isnan(qmAllProbes);
            if pltData; plot(daysSub(~nanday),qmAllProbes(~nanday),'-','color',[colAniToInspect .2]);
            scatter(daysSub(~nanday),qmAllProbes(~nanday),20,colAniToInspect,'filled'); end
            X = [ones(numel(daysSub(~nanday)),1), daysSub(~nanday)'];
            ball = (X\fdecay_inv(qmAllProbes(~nanday)));
            if pltFit; plot(daysSub(~nanday), fdecay(X*ball), 'color',colAniToInspect,'LineWidth',1); end
            fullProbeSubj{end+1} = [subjectsToInspect{ss} ' ' probes{pp}];
        end
    end
    % X = [ones(numel(daysSub),1), daysSub'];
    % plot(daysSub, fdecay(X*[nanmedian(interceptMean(:)); nanmedian(slopeMean(:))]), 'color','k','LineWidth',3)
    
    subj(cell2mat(cellfun(@(x) isempty(x), subj, 'uni', 0))) = {' '};
    if logYScale
        set(gca, 'YScale', 'log')
        yticks([1 10 100 1000])
        yticklabels([1 10 100 1000])
    end
    set(gca, 'XScale', 'log')
    ylabel(ylab)
    xlabel('Days from implantation')
    xticks([1 5 10 25 50 100])
    xticklabels([1 5 10 25 50 100])
    ylim(yRng)
    xlim([1,max(days)])
    % offsetAxes