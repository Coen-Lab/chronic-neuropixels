function plotBinnedCount(expInfoAll, subjectsToInspect, probeInfo, dayBins)

    probeSNUni = unique(expInfoAll.probeSN);
    days = cell2mat(expInfoAll.daysSinceImplant);

    clear qm_av
    for ss = 1:numel(subjectsToInspect)
        subjectIdx = contains(expInfoAll.subject,subjectsToInspect(ss));
        probes = unique(expInfoAll.probeSN(subjectIdx));
        for pp = 1:numel(probes)
    
            % Check number of uses for this probe
            [~,useNum(ss,pp)] = find(contains(probeInfo.implantedSubjects{strcmp(probeSNUni,probes(pp))},subjectsToInspect{ss}));
    
            probeIdx = contains(expInfoAll.probeSN,probes(pp));
            subAndProbeIdx = find(subjectIdx & probeIdx);
            recLocGood = expInfoAll.recLocAll(subAndProbeIdx);
    
            recLoc = unique(recLocGood);
            for rr = 1:numel(recLoc)
                recIdx = find(strcmp(expInfoAll.recLocAll,recLoc{rr}));
                for bb = 1:numel(dayBins)-1
                    days2LookAt = days(recIdx) > dayBins(bb) & days(recIdx) < dayBins(bb+1);
                    qm_av{ss}{pp}(rr,bb) = nanmean(expInfoAll.unitCount(recIdx(days2LookAt)));
                end
            end
        end
    end
    
    figure('Position', [900 700   300   300]);
    hold all
    av = [];
    for ss = 1:numel(subjectsToInspect)
        subjectIdx = contains(expInfoAll.subject,subjectsToInspect(ss));
        probes = unique(expInfoAll.probeSN(subjectIdx));
        for pp = 1:numel(probes)
            av = cat(2, av, nanmean(qm_av{ss}{pp},1)');
            plot((1:size(av,1))+0.5,nanmean(qm_av{ss}{pp},1),'color',[.5 .5 .5])
        end
    end
    nonnanNr = sum(~isnan(av),2);
    h = errorbar((1:size(av,1))+0.5,nanmean(av,2),2*nanstd(av,[],2)./sqrt(nonnanNr-1),'linestyle','-','color','k');
    h.LineWidth = 2;
    xlim([1,numel(dayBins)])
    set(gca,'XTick',1:numel(dayBins),'XTickLabel',num2str(dayBins'))
    % ylabel('P(track)')
    offsetAxes
    ylabel('Recorded units per bank')
    xlabel('Days from implantation')
