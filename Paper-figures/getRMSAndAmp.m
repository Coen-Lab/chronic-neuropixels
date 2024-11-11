function [p_rms, p_amp] = getRMSAndAmp(expInfoAll, rmsBins, ampBins, altSaveDirRMS, paramBC)

    p_rms  = nan(size(expInfoAll,1), numel(rmsBins)-1);
    p_amp  = nan(size(expInfoAll,1), numel(ampBins)-1);
    for ff = 1:size(expInfoAll.subject,1)
        % RMS
        probeName = fieldnames(expInfoAll.dataSpikes{ff});
        rec = expInfoAll.(sprintf('ephysPathP%s',probeName{1}(2:end))){ff};
        dateStr = rec(strfind(rec,'Subjects')+9+numel(expInfoAll.subject{ff})+(1:10));
        d = dir(fullfile(rec,'*ap.cbin'));
    
        % Get save dir file name
        [~,tag] = fileparts(fullfile(d.folder,d.name));
        tag = [expInfoAll.subject{ff} '_' dateStr '_' regexprep(tag,'\.','-') '.mat'];
        saveDirAni = fullfile(altSaveDirRMS,expInfoAll.subject{ff});
    
        load(fullfile(saveDirAni, tag), 'dat')
        p_rms(ff,:) = histcounts(dat.RMS,rmsBins,'Normalization','probability');
    
        % Spike amplitude
        clusters = expInfoAll.dataSpikes{ff}.(probeName{1}).clusters;
        unitType = bc_getQualityUnitType(paramBC, clusters.bc_qualityMetrics);
        idx2Use = ismember(unitType, [1 3]);
        p_amp(ff,:) = histcounts(clusters.bc_qualityMetrics.rawAmplitude(idx2Use),ampBins,'Normalization','probability');
    end