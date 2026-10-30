%% ========================================================================
%  Dimensional Accuracy Analysis – FDM Taguchi L9 Experiment
%  Ready for NAMRC 55 paper
%  CAD nominal: 60 mm (L) × 10 mm (W) × 3 mm (H)
% ========================================================================

clear; close all; clc;

%% -------------------- Data ------------------------------------------------
SpecimenID = {'S01','S02','S03','S04','S05','S06','S07','S08',...
              'S09','S10','S11','S12','S13','S14','S15','S16','S17','S18'};

PS         = {'PS01','PS01','PS02','PS02','PS03','PS03','PS04','PS04',...
              'PS05','PS05','PS06','PS06','PS07','PS07','PS08','PS08','PS09','PS09'};

Run        = [1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9];

% Process parameters
LH     = [0.10 0.10 0.10 0.10 0.10 0.10 0.20 0.20 ...
          0.20 0.20 0.20 0.20 0.30 0.30 0.30 0.30 0.30 0.30];
Speed  = [30 30 60 60 90 90 30 30 60 60 90 90 30 30 60 60 90 90];
Infill = [20 20 50 50 80 80 50 50 80 80 20 20 80 80 20 20 50 50];

% Measured means (mm)
MeanL = [59.644 59.778 59.418 59.406 59.653 59.573 59.645 59.664 ...
         59.595 59.274 59.779 59.760 59.657 59.788 59.536 59.463 59.467 59.575];
MeanW = [9.803 9.850 9.782 9.622 9.836 9.756 9.794 9.795 ...
         9.722 9.424 9.915 9.832 9.799 9.913 9.749 9.614 9.649 9.720];
MeanH = [2.890 2.872 2.975 2.926 2.992 3.040 3.070 3.005 ...
         3.058 3.047 2.991 3.064 3.002 3.002 2.958 3.084 3.047 2.994];

% Signed deviations (Measured – Nominal)
DevL = MeanL - 60;
DevW = MeanW - 10;
DevH = MeanH - 3;

% Absolute deviations
AbsDevL = abs(DevL);
AbsDevW = abs(DevW);
AbsDevH = abs(DevH);
MaxAbsDev  = max([AbsDevL; AbsDevW; AbsDevH], [], 1);
MeanAbsDev = mean([AbsDevL; AbsDevW; AbsDevH], 1);

% Aggregate by Parameter Setting (mean of two replicates)
PS_list = unique(PS, 'stable');
nPS = length(PS_list);

meanMaxAbs  = zeros(1,nPS);
meanMeanAbs = zeros(1,nPS);
meanAbsL    = zeros(1,nPS);
meanAbsW    = zeros(1,nPS);
meanAbsH    = zeros(1,nPS);
stdMaxAbs   = zeros(1,nPS);

for i = 1:nPS
    idx = strcmp(PS, PS_list{i});
    meanMaxAbs(i)  = mean(MaxAbsDev(idx));
    meanMeanAbs(i) = mean(MeanAbsDev(idx));
    meanAbsL(i)    = mean(AbsDevL(idx));
    meanAbsW(i)    = mean(AbsDevW(idx));
    meanAbsH(i)    = mean(AbsDevH(idx));
    stdMaxAbs(i)   = std(MaxAbsDev(idx));
end

%% -------------------- Figure 1: Max Absolute Deviation by PS ---------------
figure('Name','Fig1_MaxAbsDev_by_PS','Color','w','Position',[100 100 780 420]);

b = bar(meanMaxAbs, 0.65, 'FaceColor', [0.20 0.45 0.70], 'EdgeColor', 'none');
hold on;
errorbar(1:nPS, meanMaxAbs, stdMaxAbs, 'k.', 'LineWidth', 1.2, 'CapSize', 8);

% Optional threshold line (example 0.50 mm)
yline(0.50, '--r', 'LineWidth', 1.4);
text(0.3, 0.53, 'Example threshold = 0.50 mm', 'Color', 'r', 'FontSize', 10);

set(gca, 'XTick', 1:nPS, 'XTickLabel', PS_list, 'FontSize', 11, 'FontName', 'Arial');
xlabel('Parameter Setting', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Max Absolute Deviation (mm)', 'FontSize', 12, 'FontWeight', 'bold');
title('Maximum Absolute Dimensional Deviation by Parameter Setting', ...
      'FontSize', 13, 'FontWeight', 'bold');
ylim([0 0.85]);
grid on; box on;
set(gca, 'GridLineStyle', ':', 'GridAlpha', 0.4);

% Add value labels
for i = 1:nPS
    text(i, meanMaxAbs(i)+stdMaxAbs(i)+0.025, sprintf('%.3f', meanMaxAbs(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 9, 'FontName', 'Arial');
end

%% -------------------- Figure 2: Absolute Deviation by Dimension -------------
figure('Name','Fig2_AbsDev_by_Dimension','Color','w','Position',[100 100 780 420]);

data_dim = [meanAbsL; meanAbsW; meanAbsH]';
b2 = bar(data_dim, 'grouped');
b2(1).FaceColor = [0.20 0.45 0.70];   % Length
b2(2).FaceColor = [0.85 0.45 0.20];   % Width
b2(3).FaceColor = [0.30 0.65 0.40];   % Height

set(gca, 'XTick', 1:nPS, 'XTickLabel', PS_list, 'FontSize', 11, 'FontName', 'Arial');
xlabel('Parameter Setting', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Mean Absolute Deviation (mm)', 'FontSize', 12, 'FontWeight', 'bold');
title('Absolute Dimensional Deviation by Axis and Parameter Setting', ...
      'FontSize', 13, 'FontWeight', 'bold');
legend({'Length','Width','Height'}, 'Location', 'northwest', 'FontSize', 10);
ylim([0 0.75]);
grid on; box on;
set(gca, 'GridLineStyle', ':', 'GridAlpha', 0.4);

%% -------------------- Figure 3: Signed Deviation (shows under-sizing) -------
figure('Name','Fig3_SignedDev','Color','w','Position',[100 100 780 420]);

% Average signed deviation per PS
meanDevL = zeros(1,nPS);
meanDevW = zeros(1,nPS);
meanDevH = zeros(1,nPS);
for i = 1:nPS
    idx = strcmp(PS, PS_list{i});
    meanDevL(i) = mean(DevL(idx));
    meanDevW(i) = mean(DevW(idx));
    meanDevH(i) = mean(DevH(idx));
end

data_signed = [meanDevL; meanDevW; meanDevH]';
b3 = bar(data_signed, 'grouped');
b3(1).FaceColor = [0.20 0.45 0.70];
b3(2).FaceColor = [0.85 0.45 0.20];
b3(3).FaceColor = [0.30 0.65 0.40];

yline(0, 'k-', 'LineWidth', 1.0);

set(gca, 'XTick', 1:nPS, 'XTickLabel', PS_list, 'FontSize', 11, 'FontName', 'Arial');
xlabel('Parameter Setting', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Signed Deviation (mm)', 'FontSize', 12, 'FontWeight', 'bold');
title('Signed Dimensional Deviation (Measured – Nominal)', ...
      'FontSize', 13, 'FontWeight', 'bold');
legend({'Length','Width','Height'}, 'Location', 'southwest', 'FontSize', 10);
ylim([-0.70 0.15]);
grid on; box on;
set(gca, 'GridLineStyle', ':', 'GridAlpha', 0.4);

%% -------------------- Figure 4: Effect of Layer Height ----------------------
figure('Name','Fig4_Effect_LayerHeight','Color','w','Position',[100 100 700 400]);

LH_levels = [0.10 0.20 0.30];
meanMax_LH = zeros(1,3);
stdMax_LH  = zeros(1,3);
for i = 1:3
    idx = LH == LH_levels(i);
    meanMax_LH(i) = mean(MaxAbsDev(idx));
    stdMax_LH(i)  = std(MaxAbsDev(idx));
end

errorbar(LH_levels, meanMax_LH, stdMax_LH, '-o', ...
         'LineWidth', 1.8, 'MarkerSize', 9, 'MarkerFaceColor', [0.20 0.45 0.70], ...
         'Color', [0.20 0.45 0.70], 'CapSize', 10);
set(gca, 'XTick', LH_levels, 'FontSize', 11, 'FontName', 'Arial');
xlabel('Layer Height (mm)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Max Absolute Deviation (mm)', 'FontSize', 12, 'FontWeight', 'bold');
title('Effect of Layer Height on Dimensional Accuracy', ...
      'FontSize', 13, 'FontWeight', 'bold');
xlim([0.05 0.35]);
ylim([0 0.70]);
grid on; box on;

%% -------------------- Figure 5: Heatmap-style matrix of MaxAbsDev ------------
figure('Name','Fig5_Heatmap_MaxAbsDev','Color','w','Position',[100 100 600 380]);

% Create a simple matrix: rows = specimens (1-9), columns = replicate
mat = reshape(MaxAbsDev, 2, 9)';   % 9 runs × 2 replicates

imagesc(mat);
colormap(parula);
colorbar;
caxis([0 0.75]);

set(gca, 'XTick', 1:2, 'XTickLabel', {'Replicate 1','Replicate 2'}, ...
         'YTick', 1:9, 'YTickLabel', PS_list, ...
         'FontSize', 11, 'FontName', 'Arial');
xlabel('Replicate', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Parameter Setting', 'FontSize', 12, 'FontWeight', 'bold');
title('Max Absolute Dimensional Deviation (mm)', ...
      'FontSize', 13, 'FontWeight', 'bold');

% Add text values
for i = 1:9
    for j = 1:2
        text(j, i, sprintf('%.3f', mat(i,j)), ...
             'HorizontalAlignment', 'center', 'Color', 'w', ...
             'FontSize', 9, 'FontWeight', 'bold');
    end
end

%% -------------------- Optional: Save high-resolution figures --------------
% Uncomment the lines below to export publication-quality images

% print(figure(1), 'Fig1_MaxAbsDev_by_PS', '-dpng', '-r300');
% print(figure(2), 'Fig2_AbsDev_by_Dimension', '-dpng', '-r300');
% print(figure(3), 'Fig3_SignedDev', '-dpng', '-r300');
% print(figure(4), 'Fig4_Effect_LayerHeight', '-dpng', '-r300');
% print(figure(5), 'Fig5_Heatmap_MaxAbsDev', '-dpng', '-r300');

% Or save as vector EPS/PDF for the paper:
% print(figure(1), 'Fig1_MaxAbsDev_by_PS', '-depsc', '-painters');
% print(figure(1), 'Fig1_MaxAbsDev_by_PS', '-dpdf', '-painters');

disp('All dimensional analysis figures generated successfully.');
disp('Recommended figures for the paper:');
disp('  Fig.1 – Max Abs Dev by Parameter Setting (main result)');
disp('  Fig.2 – Absolute deviation by Length / Width / Height');
disp('  Fig.3 – Signed deviation (shows systematic under-sizing)');
