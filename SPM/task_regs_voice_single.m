function [] = task_regs_voice_single(s)


    subj = sprintf('%02d', s);
    subjdir = ['sub_0' subj];
    conddir = '/project/3011226.02/bids/derivatives/condition_times/';
    preprocdir = ['/project/3011226.02/bids/derivatives/fmriprep/sub-0' subj '/ses-mri01/func/'];

    firstleveldir = ['/project/3011226.02/bids/derivatives/SPM/firstlevel/'];

    
    mkdir(strcat(firstleveldir, 'sub-0', subj, '/'))
           
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
           
        
        if sum(strcmp(log_acc.task,'ERR')) == 0
                names = cell(1,7);
                onsets = cell(1,7);
                durations = cell(1,7);    
        else
            
                names = cell(1,8);
                onsets = cell(1,8);
                durations = cell(1,8);
        end
        
        
        names{1} = 'Active';
        names{2} = 'Passive';


        names{3} = 'question';
        names{4} = 'emb';
        names{5} = 'coord';
        names{6} = 'sent';
        names{7} = 'number';
        
        
        Ac = find(strcmp(log_acc.Voicesaid,"Active") & strcmp(log_acc.task,"prod") & ~strcmp(log_acc.task,"ERR"));
        Pa = find((strcmp(log_acc.Voicesaid,"Passive1") | strcmp(log_acc.Voicesaid,"Passive2") | strcmp(log_acc.Voicesaid,"Passive")) & strcmp(log_acc.task,"prod") & ~strcmp(log_acc.task,"ERR"));
        
        Qs = strcmp(log_acc.task,"Question");
        Emb = strcmp(log_acc.Voice,"Embedded") & ~strcmp(log_acc.task,"ERR");
        Coord = strcmp(log_acc.Voice,"Coordinated") & ~strcmp(log_acc.task,"ERR");
        Err = strcmp(log_acc.task,"ERR");
        
        onsets{1} = log_acc.ProdOnset(Ac);
        durations{1} = log_acc.ProdDuration(Ac);
        onsets{2} = log_acc.ProdOnset(Pa);
        durations{2} = log_acc.ProdDuration(Pa);

        
        onsets{3} = log_acc.ProdOnset(Qs);
        durations{3} = log_acc.ProdDuration(Qs);
        
        onsets{4} = log_acc.ProdOnset(Emb);
        durations{4} = log_acc.ProdDuration(Emb) ;
        onsets{5} = log_acc.ProdOnset(Coord);
        durations{5} = log_acc.ProdDuration(Coord) ;
        onsets{6} = log_acc.SentOnset;
        durations{6} = log_acc.SentDuration;
        
        onsets{7} = log_acc.NumOnset;
        durations{7} = log_acc.NumDuration;
 
           max=8;

        % duration is coded as the offset of speaking: after praat coding
       if sum(strcmp(log_acc.task,'ERR')) > 0
            names{max} = 'ERR';
            onsets{max} = log_acc.ProdOnset(Err);
            durations{max} = log_acc.ProdDuration(Err);

       end
  
        
        save(strcat(firstleveldir,'sub-0', subj, '/', 'voice_single', run_n, '.mat'), 'names','onsets','durations')
        
          
    end

end