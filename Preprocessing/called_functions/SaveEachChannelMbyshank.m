function SaveEachChannelMbyshank(animal,shank)
%Saves each file into LFP directory

exp_dir=get_exp(animal);
load([exp_dir 'exp.mat']);

dirData = dir(data_dir);
dirIndex = [dirData.isdir];
fileList = {dirData(~dirIndex).name};

%TO IGNORE CSV OR ONLY LOOK AT RDH FILES
name = contains(fileList, 'rhd');
fileList = fileList(name == 1);

LFP_dir=[exp_dir 'LFP\Full\'];
stim_dir=[exp_dir 'stimuli\'];
if exist(LFP_dir)==0
    mkdir(LFP_dir)
end
if exist(stim_dir)==0
    mkdir(stim_dir)
end
           
%create MatFile objects  
chans=([1:64])+64*(shank-1); %chans for this shank

for ch=chans   %1:numchans
writech=[LFP_dir 'LFPvoltage_ch' num2str(ch) '.mat'];     
% m = matfile(writech,'Writable',true);


eval(sprintf('m%d = matfile(writech);', ch));
eval(sprintf('m%d.Properties.Writable = true;',ch));

end

if shank==1
%create stimuli MatFile objects
wrun=matfile([stim_dir 'running.mat']);
wrew=matfile([stim_dir 'reward.mat']);
wpos=matfile([stim_dir 'position.mat']);
wlick=matfile([stim_dir 'licking.mat']);
end

%write data to all files
tic
t2=0;
for f=1:length(fileList)
   %load data
    path=data_dir;
    file=fileList{f};
    read_Intan_RHD2000_file_noselect(file,path)
    ampData = single(evalin('base', 'amplifier_data'));
    stimData = single(evalin('base', 'board_adc_data'));
    
   t1=t2+1;
   t2=t1+length(ampData(1,:))-1;

   for ch=chans  %1:numchans
   eval(sprintf('m%d.LFPvoltage(1,t1:t2)=ampData(ch,:);', ch));
   end

   if shank==1
    wrun.running(1,t1:t2)=stimData(1,:);
    wrew.reward(1,t1:t2)=stimData(2,:);
    wpos.position(1,t1:t2)=stimData(3,:);
    wlick.licking(1,t1:t2)=stimData(4,:);   
   end
   
   disp(['done with file ' num2str(f) ' of ' num2str(length(fileList)) ' total files on shank ' num2str(shank)]);
toc
end

%delete MatFile objects
for ch=chans  %1:numchans
eval(sprintf('clear m%d', ch));
end

if shank==1
clear wrun wrew wpos wlick
end
       
end
       
