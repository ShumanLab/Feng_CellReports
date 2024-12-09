%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function is used to plot bar plot of mu value with error bars and individual data points
%INPUTS
%data (format: data = {data1 data1}, each data is a array of single data points
%label (how you want to label each data column)
%colors (waht color you want each column to be)
%title_name: string of the name you want your plot to be
%save_path: path to where you want your output fig to be saved in

%NOTE: only return p value when 2 datasets are passed in
%related script: scatterBars_r_SF, scatterBars_r_SF
%Susie 1/25/2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function fig_bar = scatterBars_mu_SF(data, lab, colors, title_name,savepath) %,PLpval)
assert(length(data) == length(lab));
assert(length(data) == length(colors));
len = length(data);
data_means = NaN(1, len);
data_errs = NaN(1, len);
for i = 1:length(data)
    data_means(i) = mean(data{i});
    data_errs(i) = std(data{i}) / sqrt(length(data{i}));
end
fig_bar = figure();
hold on
xticks(1:len)
xticklabels(lab);
ylim([-3.2 3.2]);
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
if len == 2
   % [h, p] = ttest2(data{1}, data{2});
    [pval, k, K] = circ_kuipertest(data{1},data{2});
    [pval_k, f] = circ_ktest(data{1},data{2});
    [pval_w, t] = circ_wwtest(data{1},data{2});
    ylabel(['Mu Value, p value= ' num2str(pval) ' pval_k= ' num2str(pval_k) ' pval_w= ' num2str(pval_w)]);
    title(title_name);
hold off
%saveas(fig_bar,title_name, 'fig', save_path);
saveas(gca, fullfile(savepath, title_name), 'png');
end
close all