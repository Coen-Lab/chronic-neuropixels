%% WILL NOT WORK EXCEPT FOR CELIAN, ONLY AS A BACKUP

%% Get data
load('\\znas.cortexlab.net\Lab\Share\Celian\dataForPaper_ChronicImplant_stability_withQM_2024-11-08');

%% Define the rest

recInfo = cellfun(@(x) split(x,'__'),recLocAll,'uni',0);
subjectsAll = cellfun(@(x) x{1}, recInfo, 'UniformOutput', false);
probeSNAll = cellfun(@(x) x{2}, recInfo, 'UniformOutput', false);

% Get probes info
probeSNUni = unique(probeSNAll);
probeInfo = csv.checkProbeUse(str2double(probeSNUni));

% Bombcell params
e.folder = ''; e.name = ''; % hack
paramBC = bc_qualityParamValuesForUnitMatch(e, '');
% Get old version
paramBC.minSpatialDecaySlope = -0.003; % now -0.005
paramBC.minPresenceRatio = 0.2; % now 0.7
% refractory period? -- if changed would need to recompute everything
paramBC.tauR_valuesMin = 0.5/1000; % refractory period time (s), usually 0.0020 change
paramBC.tauR_valuesStep = 0.5./1000; % refractory period time (s), usually 0.0020
paramBC.tauR_valuesMax = 10./1000; % refractory period time (s), usually 0.0020
% computation of spatial decay? -- would need to recompute everything

%% Correct amplitudes for scaling factor

for rr = 1:size(expInfoAll,1)
    probeName = fieldnames(expInfoAll(rr,:).dataSpikes{1});
    clusters = expInfoAll(rr,:).dataSpikes{1}.(probeName{1}).clusters;

    if ~isempty(clusters.qualityMetrics)
        % Correct scaling factor for Npx 2.0 AND SpikeGadgets -- HACK
        if (contains(recLocAll{rr}, 'Margrie') && ~contains(recLocAll{rr}, 'Margrie002')) || contains(recLocAll{rr}, 'Wikenheiser')
            probeName = fieldnames(expInfoAll(rr,:).dataSpikes{1});
            rec = expInfoAll(rr,:).(sprintf('ephysPathP%s',probeName{1}(2:end))){1};
            dateStr = rec(31+numel(subjectsAll{rr})+(1:10));
            d = dir(fullfile(rec,'*ap.cbin'));
            datFileName = fullfile(d.folder,d.name);
    
            % Get scaling factor
            metaFile = regexprep(datFileName, 'ap.cbin', 'ap.meta');
            scalingFactor = bc_readSpikeGLXMetaFile(metaFile, 'nan');
            if contains(recLocAll{rr}, 'Margrie') && ~contains(recLocAll{rr}, 'Margrie002')
                newScalingFactor = 1.2*1e6 / (2^12) / 100 / scalingFactor;
            elseif contains(recLocAll{rr}, 'Wikenheiser')
                newScalingFactor = 0.0183 / scalingFactor;
            end
    
            % Assumes it only affects the amplitude?
            expInfoAll(rr,:).dataSpikes{1}.(probeName{1}).clusters.bc_qualityMetrics.rawAmplitude = ...
                expInfoAll(rr,:).dataSpikes{1}.(probeName{1}).clusters.bc_qualityMetrics.rawAmplitude*newScalingFactor;
        end
    end
end

%% Get amp and cnt vectors

amp = nan(1, size(expInfoAll,1));
cnt = nan(1, size(expInfoAll,1));

for rr = 1:size(expInfoAll,1)
    probeName = fieldnames(expInfoAll(rr,:).dataSpikes{1});
    clusters = expInfoAll(rr,:).dataSpikes{1}.(probeName{1}).clusters;

    if ~isempty(clusters.qualityMetrics)

        unitType = bc_getQualityUnitType(paramBC, clusters.bc_qualityMetrics);
        idx2Use = ismember(unitType, [1 3]);
 
        amp(rr) = nanmedian(clusters.bc_qualityMetrics.rawAmplitude(idx2Use)); yRng = [100 200]; %Median spk amp
        cnt(rr) = sum(idx2Use); yRng = [1 4000]; %Total units

    else
        amp(rr) = nan;
        cnt(rr) = nan;
    end
end

%% Get rms & correct for scalingFactor

saveDirRMS = 'D:\RMS';
altSaveDirRMS = '\\znas.cortexlab.net\Lab\Share\Celian\ChronicPaper\RMS';

probeType = 'NaN';
rmsq = nan(1,size(expInfoAll,1));
for ff = 1:size(expInfoAll,1)
    expInfo = expInfoAll(ff,:);
    probeName = fieldnames(expInfo.dataSpikes{1});
    rec = expInfo.(sprintf('ephysPathP%s',probeName{1}(2:end))){1};
    dateStr = rec(strfind(rec,'Subjects')+9+numel(subjectsAll{ff})+(1:10));
    d = dir(fullfile(rec,'*ap.cbin'));
    dat.fileName = fullfile(d.folder,d.name);

    % Get save dir file name
    [binFolder,tag] = fileparts(dat.fileName);
    tag = [subjectsAll{ff} '_' dateStr '_' regexprep(tag,'\.','-') '.mat'];
    saveDirAni = fullfile(saveDirRMS,subjectsAll{ff});

    % Get scaling factor
    metaFile = regexprep(dat.fileName, 'ap.cbin', 'ap.meta');
    [scalingFactor, ~, ~] = bc_readSpikeGLXMetaFile(metaFile, probeType);

    %%% PROBLEM WITH SCALING FACTOR FOR 2.0 AND SPIKEGADGETS -- HACK
    if contains(recLocAll{ff}, 'Margrie') && ~contains(recLocAll{ff}, 'Margrie002')
        scalingFactor = 1.2*1e6 / (2^12) / 100; % Neuropixels 2.0
    elseif contains(recLocAll{ff}, 'Wikenheiser')
        scalingFactor =  0.0183; %Vrange / (2^bits_encoding) / gain;
    end
    
    rmsFile = fullfile(saveDirAni, tag);
    if exist(rmsFile)
        load(rmsFile, 'dat')
        dat.RMS = dat.RMS*scalingFactor;
        rmsq(ff) = nanmedian(dat.RMS)*scalingFactor;
%         newrmsFile = strrep(rmsFile, saveDirRMS, altSaveDirRMS);
%         mkdir(fileparts(newrmsFile))
%         save(newrmsFile, 'dat')
    else
        rmsq(ff) = nan;
    end
end

%% Prune expInfoAll

fnames = fieldnames(expInfoAll);
expInfoAll_old = expInfoAll; clear expInfoAll
expInfoAll.subject = expInfoAll_old.subject;
expInfoAll.expDate = expInfoAll_old.expDate;
expInfoAll.ephysPathProbe0 = expInfoAll_old.ephysPathProbe0;
expInfoAll.ephysPathProbe1 = expInfoAll_old.ephysPathProbe1;
expInfoAll.daysSinceImplant = expInfoAll_old.daysSinceImplant;
expInfoAll.implantDate = expInfoAll_old.implantDate;
expInfoAll.dataSpikes = expInfoAll_old.dataSpikes;

% Add columns
expInfoAll.probeSN = probeSNAll;
expInfoAll.recLocAll = recLocAll';
expInfoAll.unitCount = cnt';
expInfoAll.medAmp = amp';
expInfoAll.medRMS = rmsq';

%% Save data

saveDir = '\\znas\Lab\Share\Celian\ChronicPaper';
save(fullfile(saveDir, 'data_Bimbard2024'), 'expInfoAll','probeInfo')