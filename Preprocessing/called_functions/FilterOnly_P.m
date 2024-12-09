function FilterOnly_P(animal, filtertype, numchans)
%select animal
% animal='7-18C';
% 
% %select filter
% filter='theta'; % or 'gamma' for now


% numchans=128; %probe 128D

[exp_dir]=get_exp(animal);
[ana_dir]=get_ana(animal);
LFPdir=[exp_dir 'LFP\'];

filt_dir=[ana_dir '\filters\'];
if strcmp(filtertype,'theta')==1 
load([filt_dir 'filt_5_12.mat']);
elseif strcmp(filtertype,'gamma')
load([filt_dir 'filt_30_80.mat']);
elseif strcmp(filtertype, 'fast_gamma')
load([filt_dir 'filt_90_130.mat']);
elseif strcmp(filtertype, 'slow_gamma')
load([filt_dir 'filt_30_50.mat']);
elseif strcmp(filtertype, 'ripple')
load([filt_dir 'filt_150_250.mat']);
elseif strcmp(filtertype, 'fastripple')
load([filt_dir 'filt_250_400.mat']);
elseif strcmp(filtertype, 'beta')
load([filt_dir 'filt_15_35.mat']);
elseif strcmp(filtertype, 'theta_fastgamma')
load([filt_dir 'filt_5_120.mat']);
elseif strcmp(filtertype, 'midgamma')
load([filt_dir 'filt_45_80.mat']);
end

b=filt1.tf.num;
a=filt1.tf.den;


%save filtered data
mkdir([LFPdir filtertype]);
    parfor ch=1:numchans
        chdir=[LFPdir 'LFP1000\LFPvoltage_ch', num2str(ch), '.mat'];
        if exist(chdir,'file')>0
%             load(strcat('LFPvoltage_ch', num2str(ch), '.mat'));
            fname=[LFPdir 'LFP1000\LFPvoltage_ch', num2str(ch), '.mat'];
            [LFP]=parloadLFPvoltage_notch_SF(fname);
            data=double(LFP);
            filt_data=filtfilt(b,a,data);   
            filt_data=single(filt_data);
           fname=[LFPdir filtertype '\LFPvoltage_ch' num2str(ch) filtertype '.mat'];
           parSave_filt_data(fname,filt_data);
%             save(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'), 'filt_data');
        end
    end


disp(['done with filtering ' filtertype ' for ' animal]);

end




