%% load data & set parameters

saveDir = '\\znas\Lab\Share\Celian\ChronicPaper';
load(fullfile(saveDir, 'data_Bimbard2024'))

% amp and cnt can be re-obtained running the associated part in
% "saveDataForPaper.m"

% Subjects used in paper
subjects = unique(expInfoAll.subject);
colAni = ones(numel(subjects),3)*0.5;
subjectsOtherLabs = {'Churchland001','Lignani001','Lignani002','Mainen001','Rochefort001','Rochefort002','Wikenheiser001', ...
        'Wikenheiser002','Wikenheiser003','Margrie001','Margrie002','Margrie003','Margrie004','Margrie005','Margrie006', ...
        'Margrie007','Margrie008','Duan001','Duan002'};

% Example subject
exSubj = 'AV009';
ssEx = find(contains(subjects,exSubj));
exSubjectIdx = contains(expInfoAll.subject,subjects(ssEx));
exProbes = unique(expInfoAll.probeSN(exSubjectIdx));
colAni(ssEx,:) = [0.4157    0.2392    0.6039]; 

% Full scan info
fullProbeScan = {{'0__2880'}, {'1__2880'}, {'2__2880'}, {'3__2880'}, ...
    {'0__0'}, {'1__0'}, {'2__0'}, {'3__0'}};

% Bombcell params -- NEE
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

%% Figure 3

bankSelList = {sprintf('%s__2__0',exProbes{1}) sprintf('%s__2__0',exProbes{1}) sprintf('%s__1__2880',exProbes{2}) sprintf('%s__1__2880',exProbes{2})};
day2pltList = {16 88 16 88};
depthWinList = {[800 900] [800 900] [3650 3750] [3650 3750]};
plotFullDepthRaster(expInfoAll, exSubj, exProbes, paramBC, bankSelList, day2pltList, depthWinList, fullProbeScan, colAni)

%% Figure 4

% Colors
colAni = ones(numel(subjects),3)*0.5;
colAni(ssEx,:) = [0.4157    0.2392    0.6039]; 

% Parameters
exampleAnimalOnly = 0; % change to plot A vs. B (or G vs. H)
if exampleAnimalOnly
    % Example
    subjectsToInspect = {exSubj};
    paramplt.pltIndivBank = 1; % plot individual banks
    paramplt.pltIndivProbe = 1; % plot individual probes
    paramplt.pltAllProbes = 0; % plot the full probe fit
    paramplt.pltData = 1; % plot the data
    paramplt.pltFit = 1; % plot the fit
else
    subjectsToInspect = subjects(~contains(subjects,'Wikenheiser'));
    paramplt.pltIndivBank = 0; % plot individual banks
    paramplt.pltIndivProbe = 1; % plot individual probes
    paramplt.pltAllProbes = 0; % plot the full probe fit
    paramplt.pltData = 0; % plot the data
    paramplt.pltFit = 1; % plot the fit
end
paramplt.dlim = 2;

% Plot unit count
[cnt_valueMean, cnt_slopeMean, ~, ~, cnt_subj, cnt_useNum] = ...
    plotStability(expInfoAll,subjectsToInspect,probeInfo,colAni,fullProbeScan,'count',paramplt);

if ~exampleAnimalOnly
    lme_cnt_value = plotQuantifSummary(cnt_valueMean, cnt_subj, cnt_useNum, probeInfo, exSubj, 'count', colAni(ssEx,:));
    lme_cnt_slope = plotQuantifSummary(cnt_slopeMean, cnt_subj, cnt_useNum, probeInfo, exSubj, 'slope_count', colAni(ssEx,:));
end

% Plot RMS
[rms_valueMean, rms_slopeMean, ~, ~, rms_subj, rms_useNum] = ...
    plotStability(expInfoAll,subjectsToInspect,probeInfo,colAni,fullProbeScan,'rms',paramplt);

if ~exampleAnimalOnly
    lme_rms_value = plotQuantifSummary(rms_valueMean, rms_subj, rms_useNum, probeInfo, exSubj, 'rms', colAni(ssEx,:));
    lme_rms_slope = plotQuantifSummary(rms_slopeMean, rms_subj, rms_useNum, probeInfo, exSubj, 'slope_rms', colAni(ssEx,:));
end

%% Figure 6

% Get data
altSaveDirRMS = '\\znas.cortexlab.net\Lab\Share\Celian\ChronicPaper\RMS';
rmsBins = 0:2.5:50;
ampBins = 0:25:600;
[p_rms, p_amp] = getRMSAndAmp(expInfoAll, rmsBins, ampBins, altSaveDirRMS, paramBC);

% Plot it
subjFree = {'Lignani001', 'AV043'};
subjHolder = {'Lignani002', 'Mainen001', 'Duan001', 'Duan002'};
subjMini = subjects(contains(subjects,'Margrie'))';
subjRats = subjects(contains(subjects,'Wikenheiser'))';
subjHead = subjects(~contains(subjects, [subjFree, subjHolder, subjMini, subjRats]))';

subjToPlot = subjHolder;
figure('Position', [902   765   338   213]);
subplot(121); hold all
stairs(rmsBins(1:end-1), nanmean(p_rms(contains(expInfoAll.subject, subjHead),:)), 'k')
stairs(rmsBins(1:end-1), nanmean(p_rms(contains(expInfoAll.subject, subjToPlot),:)), 'Color', [39 180 159]/256)
xlabel('RMS (uV)')
ylabel('% channels')

subplot(122); hold all
stairs(ampBins(1:end-1), nanmean(p_amp(contains(expInfoAll.subject, subjHead),:)), 'k')
stairs(ampBins(1:end-1), nanmean(p_amp(contains(expInfoAll.subject, subjToPlot),:)), 'Color', [39 180 159]/256)
xlabel('Unit amplitude (uV)')
ylabel('% unit')


%% Supplementary Figure 2

% Plot unit amplitude
subjectsToInspect = subjects(~ismember(subjects,subjectsOtherLabs));
[amp_valueMean, amp_slopeMean, ~, ~, amp_subj, amp_useNum] = ...
    plotStability(expInfoAll,subjectsToInspect,probeInfo,colAni,fullProbeScan,'amp',paramplt);
ylim([10 300])

lme_amp_value = plotQuantifSummary(amp_valueMean, amp_subj, amp_useNum, probeInfo, exSubj, 'amp', colAni(ssEx,:));
lme_amp_slope = plotQuantifSummary(amp_slopeMean, amp_subj, amp_useNum, probeInfo, exSubj, 'slope_amp', colAni(ssEx,:));

%% Supplementary Figure 3

% Which subjects to plot -- non-primary lab
subjectsToInspect = subjectsOtherLabs;

% Colors
colAni(contains(subjects,'Churchland'),:) = repmat([0.8902    0.1020    0.1098], [sum(contains(subjects,'Churchland')) 1]);
colAni(contains(subjects,'Lignani'),:) = repmat([0.4157    0.2392    0.6039], [sum(contains(subjects,'Lignani')) 1]);
colAni(contains(subjects,'Mainen'),:) = repmat([0.7    0.35   0.05], [sum(contains(subjects,'Mainen')) 1]);
colAni(contains(subjects,'Rochefort'),:) = repmat([0.2000    0.6275    0.1725], [sum(contains(subjects,'Rochefort')) 1]);
colAni(contains(subjects,'Wikenheiser'),:) = repmat([1.0 0.75 0.4], [sum(contains(subjects,'Wikenheiser')) 1]);
colAni(contains(subjects,'Margrie'),:) = repmat([0.6510    0.8078    0.8902], [sum(contains(subjects,'Margrie')) 1]);
colAni(contains(subjects,'Duan'),:) = repmat([0.3    0.8078    0.8902], [sum(contains(subjects,'Duan')) 1]);

% Parameters
paramplt.dlim = 2;
paramplt.pltIndivBank = 1;
paramplt.pltIndivProbe = 1;
paramplt.pltAllProbes = 0;
paramplt.pltData = 1;
paramplt.pltFit = 1;

% Plot unit count
[cnt_valueMean, cnt_slopeMean, cnt_interceptMean, cnt_fullProbeSubj, cnt_subj, cnt_useNum] = ...
    plotStability(expInfoAll,subjectsToInspect,probeInfo,colAni,fullProbeScan,'count',paramplt);

% Plot unit amplitude
[amp_valueMean, amp_slopeMean, amp_interceptMean, amp_fullProbeSubj, amp_subj, amp_useNum] = ...
    plotStability(expInfoAll,subjectsToInspect,probeInfo,colAni,fullProbeScan,'amp',paramplt);

% Plot RMS
[rms_valueMean, rms_slopeMean, rms_interceptMean, rms_fullProbeSubj, rms_subj, rms_useNum] = ...
    plotStability(expInfoAll,subjectsToInspect,probeInfo,colAni,fullProbeScan,'rms',paramplt);

%% Supplementary Figure 4

subjectsToInspect = subjects;
dayBins = [0 2.^(1:6) inf];
plotBinnedCount(expInfoAll, subjectsToInspect, probeInfo, dayBins)
