%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function is used to plot bar plot of mu value with doubled value for visulization purpose
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


function fig_bar = scatterdouble_mu_SF(data, lab, colors, title_name,savepath) 
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
ylim([0 720]);
for i = 1:len
    bar(i, data_means(i), 'FaceColor', "none", 'EdgeColor', 'none');
    scatter(i .* ones(1, length(data{i})), data{i},...
        30, colors{i}, 'filled',...
        'jitter', 'on', 'jitterAmount', 0.2,...
        'MarkerEdgeColor', 'black', 'LineWidth', 1.5);

%         swarmchart(i .* ones(1, length(data{i})), data{i},...
%         30, colors{i}, 'filled',...
%         'jitter', 'on', 'jitterAmount', 0.1,...
%         'MarkerEdgeColor', 'black', 'LineWidth', 1.5);


end
hold off
title(title_name);
%saveas(fig_bar,title_name, 'fig', save_path);
saveas(gca, fullfile(savepath, title_name), 'svg');
saveas(gca, fullfile(savepath, title_name), 'png');

end