function plotFullDepthRaster(expInfoAll, exSubject, exProbes, paramBC, bankSelList, day2pltList, depthWinList, fullProbeScan, colAni)

    for pp = 1:numel(exProbes)
        fullProbeScanSpec = cellfun(@(x) [exSubject '__' exProbes{pp} '__' x{1}], fullProbeScan, 'uni', 0);
    
        meas = cell(1,numel(fullProbeScanSpec));
        for rr = 1:numel(fullProbeScanSpec)
            recIdx = find(strcmp(expInfoAll.recLocAll,fullProbeScanSpec{rr}));
            daysSinceImplant{rr} = expInfoAll.daysSinceImplant(recIdx); % just to plot the same
            d = split(fullProbeScan{rr},'__');
            depthBins{rr} = str2num(d{2}) + (0:20:2880);
            meas{rr} = nan(numel(recIdx),numel(depthBins{rr})-1);
            for dd = 1:numel(recIdx)
                probeName = fieldnames(expInfoAll.dataSpikes{recIdx(dd)});
                clusters = expInfoAll.dataSpikes{recIdx(dd)}.(probeName{1}).clusters;
                for depth = 1:numel(depthBins{rr})-1
                    depthNeuronIdx = (clusters.depths > depthBins{rr}(depth)) & (clusters.depths < depthBins{rr}(depth+1));
                    unitType = bc_getQualityUnitType(paramBC, clusters.bc_qualityMetrics);
                    meas{rr}(dd,depth) = sum(clusters.qualityMetrics.firing_rate(depthNeuronIdx & (unitType == 1)));
                end
            end
        end
    
        fun = @(x) x.^0.5;
        colors = winter(5);
        figure('Position', [680   282   441   685], 'Name', [exSubject '__' exProbes{pp}]);
        for rr = 1:numel(fullProbeScanSpec)
            ax(rr) = subplot(2,4,rr);
            imagesc(1:size(meas{rr},1),depthBins{rr},fun(meas{rr}'))
            set(gca,'YDir','normal')
            c = colormap("gray"); c = flipud(c);
            colormap(c)
            clim([0 fun(20)]);
            xticks(1:size(meas{rr},1))
            xticklabels(cell2mat(daysSinceImplant{rr}))
    
            % Plot boxes around zoom in
            for ll = 1:numel(bankSelList)
                bankSel = bankSelList{ll};
                day2plt = day2pltList{ll};
                depthWin = depthWinList{ll};
                if contains(fullProbeScanSpec{rr}, bankSel)
                    rectangle('Position', [day2plt-1 depthWin(1) 2 diff(depthWin)],'LineWidth',3,'EdgeColor','r')
                end
            end
        end
    end
end