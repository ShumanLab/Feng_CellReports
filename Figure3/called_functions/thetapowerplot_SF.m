

animals = {'TS112-0' 'TS114-0' 'TS114-1'  'TS111-1' 'TS111-2' 'TS115-2' 'TS116-3' ...
    'TS116-0' 'TS116-2' 'TS117-0' 'TS118-4'  'TS118-0' 'TS118-3' 'TS88-3' 'TS90-0' ...
    'TS89-1' 'TS110-0' 'TS114-3' 'TS113-1' 'TS117-4' 'TS118-2' 'TS86-1' 'TS89-3' ...
    'TS91-1' 'TS110-3' 'TS112-1' 'TS114-2' 'TS113-3' 'TS113-2' 'TS115-1' 'TS116-1' ...
    'TS117-1' 'TS86-2' 'TS89-2' 'TS91-2' 'TS90-2'};
state = 'running';
filtertype = 'theta';
for anim=1:length(animals)
    animal=animals{anim};
%need to handle the missing shank situation
     [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshank_SF(animal);
     exp_dir=get_exp(animal);
     [ana_dir]=get_ana(animals);
     load([ana_dir '\probe_data\ECHIP512.mat'])
     expinfo = load([exp_dir 'exp.mat']);
    % badchannels = expinfo.badchannels;
     load([exp_dir '\LFP\PowerByChannel\' state '\seizclean\'  animal '_' filtertype 'powerbychannel.mat']);

    plot(NPower(:,CA1DGshank),(1:64));
    ylim([0 65]);
    xlim([0 120000]);
    xlabel([filtertype ' power']);
    ylabel('channel position');
 
    title([animal ' master CA1DG shank ' filtertype]);
    savepath = 'L:\Susie\SummerEphysHPCEC\AnalysisOutput\HPCEC_analysis\power_ana\byanimal\';
    if exist(savepath)==0
       mkdir(savepath);
    end
    saveas(gca, fullfile(savepath, animal), 'png');

end