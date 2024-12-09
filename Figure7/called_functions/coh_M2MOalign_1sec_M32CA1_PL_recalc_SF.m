function coh_M2MOalign_1sec_M32CA1_PL_recalc_SF(animals)
    for a = 1:length(animals)
        animal = animals{a};
        [CA1DGshank, CA3shank, MECshank, LECshank]=getCA1DGCA3ECshankFULL_SF(animal);
        shanks = MECshank;
        refshank = CA1DGshank(1);
        for shk = 1:length(shanks)
            shank = shanks(shk);
            [ch]=getchannels(animal,shank);  % get channels
            group = ch.group;
            exp_dir=get_exp(animal);
            [ana_dir]=get_ana(animal);
            load([exp_dir 'exp.mat']); %load each animal's exp file for animal info
            load(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) '\cells.mat'], 'unit') %read unit info from cells.m, for now susie only saved unit info in cells.m, not MUA
    
            nclusters=size(unit,2);
            if group == '3wP' | group == '8wP' 
                load([exp_dir '\M2MOcoh_1sec.mat'],'coh_matrix', 'coh_matrix_run', 'aligned_coh_matrix', 'track','run_matrix', 'align_ind_run', 'align_ind',  'align_ind_run_3sec_consec', 'align_ind_3sec_consec'); 
                M2MOalign_ind = align_ind_3sec_consec; %align_ind is whole track1 length, with 1 as runing + aligned

                 % select just the bins with run time = 1
               for i = 1: length(run_matrix)
                   if run_matrix(i,1) == 0
                       M2MOalign_ind(i) = 0;
                   end
               end

            elseif group == '3wC' | group == '8wC' 
                load([exp_dir '\M2MOcoh_1sec.mat'],'coh_matrix', 'coh_matrix_run', 'track', 'run_matrix');  
                M2MOalign_ind = run_matrix(:,1);
            end
    
            % build new spike matrix for each animal 
            % make DGCA1align_runtime_ind matrix at 25000hz
            win_sz = 25000;
            counter = 1;
            for i = 1: length(M2MOalign_ind)
                if counter < length(M2MOalign_ind)*25000 - win_sz
                    if M2MOalign_ind(i) == 1
                        M2MOalign_runtime_ind_25000(counter:counter+win_sz-1) = 1;
                    else
                        M2MOalign_runtime_ind_25000(counter:counter+win_sz-1) = 0;
                    end
                else
                    if M2MOalign_ind(i) == 1
                        M2MOalign_runtime_ind_25000(counter:length(M2MOalign_ind)*25000) = 1;
                    else
                        M2MOalign_runtime_ind_25000(counter:length(M2MOalign_ind)*25000) = 0;
                    end
                end

               counter = counter +25000;
            end
            for c=1:nclusters %loop through all clusters this shank has
                if unit(c).correctch <= ch.MEC31 & unit(c).correctch >= ch.MEC32 % only process DG cells here
                    if ~isempty(unit(c).spiketimesnew) %deal with units with no running spiketimes
                         for s = 1:length(unit(c).spiketimesnew)
                             if unit(c).spiketimesnew(s) <= length(M2MOalign_ind)*25000  %manually control I'm in track1
                                 if M2MOalign_runtime_ind_25000(unit(c).spiketimesnew(s)) ==1
                                     unit(c).M2MOcoh_align_binary(s) = 1; %set to true
                                 else
                                     unit(c).M2MOcoh_align_binary(s) = 0;
                                 end
                             end
                                         
                         end
                         unit(c).spiketimesnew_track1align = unit(c).spiketimesnew(unit(c).M2MOcoh_align_binary(:) == 1);
                         spk=double(unit(c).spiketimesnew_track1align); 
                         spks=spk/25000; %in seconds
                         ISI=diff(spks); %calculates differences between adjacent spiketimes for this cluster 
                         %calc refrac violation 
                         %refravio = [];
                         refravio= (sum(ISI<=0.002)/length(spk))*100;
    
                         if ~isempty(spk) %don't go through the following if spk is empty
                            % load CA1 ref LFP
                            [chref]=getchannels(animal,refshank);
                            refch=chref.MidPyr;
                            load([ana_dir '\probe_data\ECHIP512.mat'])
                            CA1refch=probelayout(refch,refshank);
                            %deal with if bad ch is refch
                            while 1
                                 if ~ismember(CA1refch, badchannels)
                                     break
                                 end
                                 refch = refch + 1; %find next ch as ref ch if current on is a bad ch
                                 CA1refch=probelayout(refch,refshank);
                            end
                            % calc r val for selected units
                            load([exp_dir '\LFP\theta\LFPvoltage_ch' num2str(CA1refch) 'theta.mat']); %loads filt_data
                            [PL]=phaselockunitLV_SF(spk,filt_data);
        
                            CA1thetaPL_aligned{c}=PL;
                            disp(['Done with animal ' animal 'for shank ' num2str(shank) 'cluster' num2str(c)])
    
                         else
                             CA1thetaPL_aligned{c} = nan;
                             disp(['Empty cluster ' num2str(c)])               
                         end
                    end
                else
                    CA1thetaPL_aligned{c} = nan;
                end %end of if statement
    
            % gather the to be saved list
     
                if unit(c).correctch <= ch.MEC31 & unit(c).correctch >= ch.MEC32 % only process DG cells here
                    numspikes(c) = length(unit(c).spiketimesnew_track1align);
                    correctch(c) = unit(c).correctch;
                    refravio(c)= refravio;
                else
                    numspikes(c) = nan;
                    correctch(c) = nan;
                    refravio(c)= nan;
                end
            end %end for cluster
    
            units.CA1thetaPL=CA1thetaPL_aligned;
            units.numspikes=numspikes;
            units.correctclusterch = correctch;
            units.refravio = refravio;
            save(['Y:\Susie\2020\Summer_Ephys_ALL\kilosort\' animal '\shank' num2str(shank) 'M32CA1_PL_whenM2MOcohalign_running1sec_2sec-consec.mat'],'units') %save final units info as shank_units.mat in animal folder under kilosort
            disp(['Done with animal ' animal 'for shank ' num2str(shank)])
           clear numspikes correctch refravio CA1thetaPL_aligned
        end %end of shank
    end %end of animal
    clear all

end