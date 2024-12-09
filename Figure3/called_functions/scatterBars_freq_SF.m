%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function is used to plot bar plot with error bars and individual data points
%INPUTS
%data (format: data = {data1 data1}, each data is a array of single data points
%label (how you want to label each data column)
%colors (waht color you want each column to be)
%title_name: string of the name you want your plot to be
%save_path: path to where you want your output fig to be saved in

%NOTE: run t test and return p value when 2 datasets are passed in;
%run 1anova and retuen p values when 3 datasets are passed in;
%related script: scatterBars_r_SF, scatterdouble_mu_SF
%Susie 10/4/2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [results, fig_bar] = scatterBars_freq_SF(data, lab, colors, title_name,save_path)
assert(length(data) == length(lab));
assert(length(data) == length(colors));
len = length(data);
data_means = NaN(1, len);
data_errs = NaN(1, len);
for i = 1:length(data)
    data_means(i) = nanmean(data{i});
    data_errs(i) = std(data{i}) / sqrt(length(data{i}));
end

if len == 2
    [h, p] = ttest2(data{1}, data{2});
    %p = ranksum(data{1}, data{2});
    ylabel(['r Value, p value = ' num2str(p)]);
    title(title_name);
    hold off

elseif len == 3 %perform unbalanced anova if len is 3 (or more)
    y = [data{1}, data{2}, data{3}];
    g1 = {};
    g2 = {};
    g3 = {};
    for k = 1:length(data{1})
        g1{k} = lab(1);
    end
    for k = 1:length(data{2})
        g2{k} = lab(2);
    end
    for k = 1:length(data{3})
        g3{k} = lab(3);
    end
  
    g = [g1 g2 g3];
    g = cell2table(g);
    g = table2array(g);
    [~, ~, stats] = anova1(y,g);
    results = multcompare(stats);
    title(title_name);
    hold off
    close all;
end

fig_bar = figure();
hold on
xticks(1:len)
xticklabels(lab);
ylim([30 80]);
for i = 1:len
    bar(i, data_means(i), colors{i});
    scatter(i .* ones(1, length(data{i})), data{i},...
        30, colors{i}, 'filled',...
        'jitter', 'on', 'jitterAmount', 0.1,...
        'MarkerEdgeColor', 'black', 'LineWidth', 1.5);
end
errs = errorbar(1:len, data_means, data_errs, 'LineWidth', 2.5, 'CapSize', 15);
errs.LineStyle = 'none';
errs.Color = 'black';
title(title_name);
if len == 3
    ylabel(['Freq, p(Cv3p)' num2str(results(1,6)) ' p(Cv8p)' num2str(results(2,6)) ' p(3pv8p)' num2str(results(3,6))]);
elseif len == 2
    ylabel(['Freq, p value = ' num2str(p)]);
end

saveas(gca, fullfile(save_path, title_name), 'png');
%close all
