%% Surface Roughness Comparison Analysis - Specimens 1-9
% This script loads raw and summary roughness data, performs comparisons,
% and generates publication-quality figures.
%
% Parameters analyzed: Ra, Rq, Rz, Rt (all in micrometers)
% Surfaces: Top, Bottom, Left, Right
% Specimens: 1 through 9

clear; close all; clc;

%% ==================== LOAD DATA ====================
% Adjust paths if needed
rawFile     = 'Raw_Roughness_Results_Specimens1-9.csv';
summaryFile = 'Summary_Ra_Rq_Rz_Rt_Specimens1-9.csv';

% Read tables (preserve original headers so CV_Ra_% stays usable)
rawT = readtable(rawFile, 'VariableNamingRule', 'preserve');
sumT = readtable(summaryFile, 'VariableNamingRule', 'preserve');

% Ensure categorical for easier grouping
rawT.Surface  = categorical(rawT.Surface, {'Top','Bottom','Left','Right'});
rawT.Specimen = categorical(rawT.Specimen);
sumT.Surface  = categorical(sumT.Surface, {'Top','Bottom','Left','Right'});
sumT.Specimen = categorical(sumT.Specimen);

% Handle the CV column name robustly (MATLAB may alter % character)
cvColName = '';
possibleCV = {'CV_Ra_%', 'CV_Ra_', 'CV_Ra', 'CV_Ra_pct'};
for k = 1:numel(possibleCV)
    if ismember(possibleCV{k}, sumT.Properties.VariableNames)
        cvColName = possibleCV{k};
        break;
    end
end
if isempty(cvColName)
    % fallback: find any column that starts with CV_Ra
    vn = sumT.Properties.VariableNames;
    idxCV = find(startsWith(vn, 'CV_Ra'), 1);
    if ~isempty(idxCV)
        cvColName = vn{idxCV};
    else
        error('Could not find CV_Ra column in summary table. Available columns:\n%s', strjoin(vn, ', '));
    end
end
fprintf('Using CV column name: %s\n', cvColName);

disp('Data loaded successfully.');
disp(['Raw data rows: ' num2str(height(rawT))]);
disp(['Summary data rows: ' num2str(height(sumT))]);

%% ==================== COLOR & STYLE SETTINGS ====================
% Distinct colors for surfaces
surfColors = containers.Map(...
    {'Top','Bottom','Left','Right'}, ...
    {[0.85 0.33 0.10], [0.00 0.45 0.74], [0.47 0.67 0.19], [0.49 0.18 0.56]});

specimenList = 1:9;
surfaceList  = {'Top','Bottom','Left','Right'};
paramList    = {'Ra_um','Rq_um','Rz_um','Rt_um'};
paramLabels  = {'Ra (\mum)','Rq (\mum)','Rz (\mum)','Rt (\mum)'};

%% ==================== FIGURE 1: Mean Ra by Specimen & Surface (Bar) ====================
figure('Name','Mean Ra by Specimen and Surface','Color','w','Position',[100 100 1000 550]);

% Prepare matrix: rows = specimens, columns = surfaces
Ra_mat = nan(9,4);
SD_mat = nan(9,4);
for i = 1:9
    for j = 1:4
        idx = sumT.Specimen == categorical(i) & sumT.Surface == surfaceList{j};
        if any(idx)
            Ra_mat(i,j) = sumT.Mean_Ra_um(idx);
            SD_mat(i,j) = sumT.SD_Ra_um(idx);
        end
    end
end

b = bar(Ra_mat, 'grouped');
hold on;
% Add error bars
ngroups = size(Ra_mat,1);
nbars   = size(Ra_mat,2);
groupwidth = min(0.8, nbars/(nbars+1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1)*groupwidth/(2*nbars);
    errorbar(x, Ra_mat(:,i), SD_mat(:,i), 'k.', 'LineWidth',1.2, 'CapSize',6);
    b(i).FaceColor = surfColors(surfaceList{i});
end
hold off;

xlabel('Specimen','FontSize',12,'FontWeight','bold');
ylabel('Mean Ra (\mum)','FontSize',12,'FontWeight','bold');
title('Mean Arithmetic Average Roughness (Ra) by Specimen and Surface','FontSize',14);
legend(surfaceList, 'Location','northwest','FontSize',10);
set(gca,'XTick',1:9,'XTickLabel',string(1:9),'FontSize',11);
grid on; box on;
ylim([0 max(Ra_mat(:)+SD_mat(:))*1.15]);

% Annotate high outliers (Top surfaces of 2,5,8,9)
text(2, Ra_mat(2,1)+SD_mat(2,1)+1.5, sprintf('%.1f',Ra_mat(2,1)), ...
    'HorizontalAlignment','center','FontSize',8,'Color',surfColors('Top'));
text(5, Ra_mat(5,1)+SD_mat(5,1)+1.5, sprintf('%.1f',Ra_mat(5,1)), ...
    'HorizontalAlignment','center','FontSize',8,'Color',surfColors('Top'));
text(8, Ra_mat(8,1)+SD_mat(8,1)+1.5, sprintf('%.1f',Ra_mat(8,1)), ...
    'HorizontalAlignment','center','FontSize',8,'Color',surfColors('Top'));
text(9, Ra_mat(9,1)+SD_mat(9,1)+1.5, sprintf('%.1f',Ra_mat(9,1)), ...
    'HorizontalAlignment','center','FontSize',8,'Color',surfColors('Top'));

%% ==================== FIGURE 2: All Parameters - Grouped Bars (4 subplots) ====================
figure('Name','Mean Roughness Parameters','Color','w','Position',[50 50 1200 800]);

params_mean = {'Mean_Ra_um','Mean_Rq_um','Mean_Rz_um','Mean_Rt_um'};
ylims = [0 30; 0 50; 0 200; 0 250];  % approximate y-limits

for p = 1:4
    subplot(2,2,p);
    mat = nan(9,4);
    for i = 1:9
        for j = 1:4
            idx = sumT.Specimen == categorical(i) & sumT.Surface == surfaceList{j};
            if any(idx)
                mat(i,j) = sumT.(params_mean{p})(idx);
            end
        end
    end
    b = bar(mat, 'grouped');
    for i = 1:4
        b(i).FaceColor = surfColors(surfaceList{i});
    end
    xlabel('Specimen');
    ylabel(paramLabels{p});
    title(paramLabels{p});
    set(gca,'XTick',1:9);
    legend(surfaceList,'Location','best','FontSize',8);
    grid on; box on;
    ylim(ylims(p,:));
end
sgtitle('Mean Roughness Parameters by Specimen and Surface','FontSize',14,'FontWeight','bold');

%% ==================== FIGURE 3: Boxplots of Raw Ra by Surface ====================
figure('Name','Ra Distribution by Surface','Color','w','Position',[100 100 900 500]);

% Extract Ra for each surface
Ra_Top    = rawT.Ra_um(rawT.Surface=='Top');
Ra_Bottom = rawT.Ra_um(rawT.Surface=='Bottom');
Ra_Left   = rawT.Ra_um(rawT.Surface=='Left');
Ra_Right  = rawT.Ra_um(rawT.Surface=='Right');

% Use boxplot with grouping
boxplot(rawT.Ra_um, rawT.Surface, 'Colors','k', 'Symbol','r+');
hold on;
% Overlay individual points with jitter
surfaces = categories(rawT.Surface);
for s = 1:4
    idx = rawT.Surface == surfaces{s};
    x = s + 0.15*(rand(sum(idx),1)-0.5);
    scatter(x, rawT.Ra_um(idx), 40, surfColors(surfaces{s}), 'filled', ...
        'MarkerFaceAlpha',0.6, 'MarkerEdgeColor','k');
end
hold off;
ylabel('Ra (\mum)','FontSize',12,'FontWeight','bold');
xlabel('Surface','FontSize',12,'FontWeight','bold');
title('Distribution of Ra Values Across All Specimens by Surface','FontSize',13);
grid on; box on;
set(gca,'FontSize',11);

%% ==================== FIGURE 4: Heatmap of Mean Ra ====================
figure('Name','Heatmap Mean Ra','Color','w','Position',[150 150 700 500]);

imagesc(Ra_mat');
colormap(parula);
colorbar;
c = colorbar;
c.Label.String = 'Mean Ra (\mum)';
c.Label.FontSize = 11;

set(gca, 'XTick',1:9, 'XTickLabel',string(1:9), ...
         'YTick',1:4, 'YTickLabel',surfaceList, ...
         'FontSize',11);
xlabel('Specimen','FontWeight','bold');
ylabel('Surface','FontWeight','bold');
title('Heatmap of Mean Ra (\mum)','FontSize',13);

% Add text annotations
for i = 1:9
    for j = 1:4
        val = Ra_mat(i,j);
        if ~isnan(val)
            if val > 10
                txtColor = 'w';
            else
                txtColor = 'k';
            end
            text(i, j, sprintf('%.2f',val), 'HorizontalAlignment','center', ...
                'FontSize',8, 'Color',txtColor);
        end
    end
end

%% ==================== FIGURE 5: Coefficient of Variation (CV) of Ra ====================
figure('Name','CV of Ra','Color','w','Position',[100 100 1000 500]);

CV_mat = nan(9,4);
for i = 1:9
    for j = 1:4
        idx = sumT.Specimen == categorical(i) & sumT.Surface == surfaceList{j};
        if any(idx)
            CV_mat(i,j) = sumT.(cvColName)(idx);
        end
    end
end

b = bar(CV_mat, 'grouped');
for i = 1:4
    b(i).FaceColor = surfColors(surfaceList{i});
end
xlabel('Specimen','FontWeight','bold');
ylabel('CV of Ra (%)','FontWeight','bold');
title('Coefficient of Variation of Ra (Replicate Consistency)','FontSize',13);
legend(surfaceList,'Location','northwest');
set(gca,'XTick',1:9);
grid on; box on;
yline(20, '--r', 'CV = 20%', 'LineWidth',1.5, 'LabelHorizontalAlignment','left');

%% ==================== FIGURE 6: Scatter Ra vs Rq (all data) ====================
figure('Name','Ra vs Rq','Color','w','Position',[100 100 700 550]);

hold on;
for s = 1:4
    idx = rawT.Surface == surfaceList{s};
    scatter(rawT.Ra_um(idx), rawT.Rq_um(idx), 60, ...
        'MarkerFaceColor',surfColors(surfaceList{s}), ...
        'MarkerEdgeColor','k', 'MarkerFaceAlpha',0.7, ...
        'DisplayName',surfaceList{s});
end
% Theoretical line Rq ≈ 1.25 * Ra for Gaussian surfaces (approx)
xline = linspace(0, max(rawT.Ra_um)*1.05, 100);
plot(xline, 1.25*xline, 'k--', 'LineWidth',1.5, 'DisplayName','Rq = 1.25·Ra');
hold off;
xlabel('Ra (\mum)','FontWeight','bold');
ylabel('Rq (\mum)','FontWeight','bold');
title('Relationship between Ra and Rq','FontSize',13);
legend('Location','northwest');
grid on; box on;
axis equal tight;

%% ==================== FIGURE 7: Side-by-side comparison of Top surfaces ====================
% Highlight specimens with unusually high Top Ra (2,5,8,9)
figure('Name','Top Surface Detailed Comparison','Color','w','Position',[80 80 1100 600]);

subplot(1,2,1);
topIdx = rawT.Surface == 'Top';
boxplot(rawT.Ra_um(topIdx), rawT.Specimen(topIdx), 'Colors','k');
ylabel('Ra (\mum)');
xlabel('Specimen');
title('Ra of Top Surfaces by Specimen');
grid on; box on;

subplot(1,2,2);
% Mean + SD for Top only
topMean = Ra_mat(:,1);
topSD   = SD_mat(:,1);
bar(topMean, 'FaceColor',surfColors('Top'));
hold on;
errorbar(1:9, topMean, topSD, 'k.', 'LineWidth',1.3, 'CapSize',8);
hold off;
xlabel('Specimen');
ylabel('Mean Ra (\mum)');
title('Mean ± SD of Top Surface Ra');
set(gca,'XTick',1:9);
grid on; box on;

sgtitle('Focus on Top Surfaces (highest roughness variation)','FontSize',13,'FontWeight','bold');

%% ==================== FIGURE 8: Radar / Spider plot style comparison (selected) ====================
% Normalize parameters for a few representative specimens
figure('Name','Normalized Parameter Profiles','Color','w','Position',[100 100 900 700]);

% Select a few interesting specimens: smooth (4), moderate (1), rough (8,9)
selSpec = [4, 1, 8, 9];
nSel = numel(selSpec);

% For Top surface only
params_for_radar = {'Mean_Ra_um','Mean_Rq_um','Mean_Rz_um','Mean_Rt_um'};
maxVals = [max(sumT.Mean_Ra_um), max(sumT.Mean_Rq_um), max(sumT.Mean_Rz_um), max(sumT.Mean_Rt_um)];

colors_sel = lines(nSel);
theta = linspace(0, 2*pi, 5);  % 4 params + close

for k = 1:nSel
    subplot(2,2,k);
    sp = selSpec(k);
    vals = zeros(1,4);
    for p = 1:4
        idx = sumT.Specimen == categorical(sp) & sumT.Surface == 'Top';
        vals(p) = sumT.(params_for_radar{p})(idx) / maxVals(p);
    end
    vals = [vals vals(1)];  % close the polygon
    polarplot(theta, vals, '-o', 'LineWidth',2, 'Color',colors_sel(k,:), ...
        'MarkerFaceColor',colors_sel(k,:));
    thetaticks(rad2deg(theta(1:4)));
    thetaticklabels({'Ra','Rq','Rz','Rt'});
    title(sprintf('Specimen %d – Top (normalized)', sp));
    rlim([0 1.05]);
end
sgtitle('Normalized Roughness Parameter Profiles (Top Surface)','FontSize',13);

%% ==================== STATISTICAL SUMMARY TABLE ====================
fprintf('\n========== SUMMARY STATISTICS ==========\n');
fprintf('%-10s %-8s %8s %8s %8s %8s %8s\n', ...
    'Specimen','Surface','Mean_Ra','SD_Ra','Mean_Rq','Mean_Rz','Mean_Rt');
fprintf('%s\n', repmat('-',1,70));
for i = 1:height(sumT)
    fprintf('%-10d %-8s %8.3f %8.3f %8.3f %8.3f %8.3f\n', ...
        sumT.Specimen(i), char(sumT.Surface(i)), ...
        sumT.Mean_Ra_um(i), sumT.SD_Ra_um(i), ...
        sumT.Mean_Rq_um(i), sumT.Mean_Rz_um(i), sumT.Mean_Rt_um(i));
end

%% ==================== OPTIONAL: SAVE FIGURES ====================
% Uncomment the lines below to automatically save all figures as PNG
%
% figHandles = findall(0,'Type','figure');
% for f = 1:numel(figHandles)
%     fname = sprintf('Roughness_Fig%02d.png', f);
%     saveas(figHandles(f), fname);
%     fprintf('Saved: %s\n', fname);
% end

%% ==================== END ====================
disp(' ');
disp('All figures generated successfully.');
disp('You can now explore each figure window.');
disp('To save figures, uncomment the save block at the end of the script.');
