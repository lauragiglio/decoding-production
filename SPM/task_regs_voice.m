function [] = task_regs_voice(s)


    subj = sprintf('%02d', s);
    subjdir = ['sub_0' subj];
    conddir = '/project/3011226.02/bids/derivatives/condition_times/';
    preprocdir = ['/project/3011226.02/bids/derivatives/fmriprep/sub-0' subj '/ses-mri01/func/'];
    firstleveldir = ['/project/3011226.02/bids/derivatives/SPM/firstlevel/'];

    
    %mkdir(strcat(firstleveldir, 'sub-0', subj, '/'))
           
    nruns = 6;
    
    
    for i = 1:nruns
        clear names
        clear onsets
        clear durations
       
        run_n = string(i)
        
        % import presentation logfile with time of trials
        log_acc = readtable(strcat(conddir, subjdir, "_log_acc-times_run-", run_n, ".csv"));

%         for t = 1:size(log_acc,1)
%             if log_acc.Acceptable(t) == 2
%                 log_acc.task{t} = 'ERR';
%             end
%         end
         log_cat = readtable('/project/3011226.02/scripts/SPM/voice.csv'); 
        
    if sum(strcmp(log_acc.task,'ERR')) == 0
        names = cell(1,7+6);
        onsets = cell(1,7+6);
        durations = cell(1,7+6);
    else
        names = cell(1,8+6);
        onsets = cell(1,8+6);
        durations = cell(1,8+6);
    end
        
        
        names{1} = 'A1';
        names{2} = 'A2';
        names{3} = 'A3';
        names{4} = 'A4';
        names{5} = 'P1';
        names{6} = 'P2';
        names{7} = 'P3';
        names{8} = 'P4';

        names{3+6} = 'question';
        names{4+6} = 'emb';
        names{5+6} = 'coord';
        names{6+6} = 'sent';
        names{7+6} = 'number';
        
        
        Ac = find(strcmp(log_acc.Voicesaid,"Active") & strcmp(log_acc.task,"prod") & ~strcmp(log_acc.task,"ERR"));
        Pa = find((strcmp(log_acc.Voicesaid,"Passive1") | strcmp(log_acc.Voicesaid,"Passive2") | strcmp(log_acc.Voicesaid,"Passive")) & strcmp(log_acc.task,"prod") & ~strcmp(log_acc.task,"ERR"));
        
        log_cat.(strcat('Ac',run_n))(s) = length(Ac);
        log_cat.(strcat('Pa',run_n))(s) = length(Pa);
        
        Qs = strcmp(log_acc.task,"Question");
        Emb = strcmp(log_acc.Voice,"Embedded") & ~strcmp(log_acc.task,"ERR");
        Coord = strcmp(log_acc.Voice,"Coordinated") & ~strcmp(log_acc.task,"ERR");
        Err = strcmp(log_acc.task,"ERR");
        

        
        onsets{1} = log_acc.ProdOnset(Ac(1:4:end));
        durations{1} = log_acc.ProdDuration(Ac(1:4:end));
        onsets{2} = log_acc.ProdOnset(Ac(2:4:end));
        durations{2} = log_acc.ProdDuration(Ac(2:4:end));
        onsets{3} = log_acc.ProdOnset(Ac(3:4:end));
        durations{3} = log_acc.ProdDuration(Ac(3:4:end));
        onsets{4} = log_acc.ProdOnset(Ac(4:4:end));
        durations{4} = log_acc.ProdDuration(Ac(4:4:end));       
        
        onsets{5} = log_acc.ProdOnset(Pa(1:4:end));
        durations{5} = log_acc.ProdDuration(Pa(1:4:end));
        onsets{6} = log_acc.ProdOnset(Pa(2:4:end));
        durations{6} = log_acc.ProdDuration(Pa(2:4:end));        
        onsets{7} = log_acc.ProdOnset(Pa(3:4:end));
        durations{7} = log_acc.ProdDuration(Pa(3:4:end));        
        onsets{8} = log_acc.ProdOnset(Pa(4:4:end));
        durations{8} = log_acc.ProdDuration(Pa(4:4:end));
        

        onsets{3+6} = log_acc.ProdOnset(Qs);
        durations{3+6} = log_acc.ProdDuration(Qs);
        
        onsets{4+6} = log_acc.ProdOnset(Emb);
        durations{4+6} = log_acc.ProdDuration(Emb) ;
        onsets{5+6} = log_acc.ProdOnset(Coord);
        durations{5+6} = log_acc.ProdDuration(Coord) ;
        onsets{6+6} = log_acc.SentOnset;
        durations{6+6} = log_acc.SentDuration;
        
        onsets{7+6} = log_acc.NumOnset;
        durations{7+6} = log_acc.NumDuration;
     
           max=8+6;

        % duration is coded as the offset of speaking: after praat coding
       if sum(strcmp(log_acc.task,'ERR')) > 0
            names{max} = 'ERR';
            onsets{max} = log_acc.ProdOnset(Err);
            durations{max} = log_acc.ProdDuration(Err);

       end
  
        writetable(log_cat,'/project/3011226.02/scripts/SPM/voice.csv')
        save(strcat(firstleveldir,'sub-0', subj, '/', 'voice_cat', run_n, '.mat'), 'names','onsets','durations')
        
          
    end

end