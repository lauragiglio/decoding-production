function [] = task_regs_sent_prod(s)
%clear all
%cd '/project/3011226.02/scripts'
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
    
    log_acc = readtable(strcat(conddir, subjdir, "_log_acc-times_run-", run_n, ".csv"));
    
    %     for t = 1:size(log_acc,1)
    %         if log_acc.Acceptable(t) == 2
    %             log_acc.task{t} = 'ERR';
    %         end
    %     end
    
    
    count=0;
    sent=[];
    for trial=1:size(log_acc,1)
        if log_acc.task(trial) ~= "ERR" && log_acc.task(trial) ~= "Filler" && log_acc.task(trial) ~= "Question"
            sent = [sent trial];
            count = count+1;
        end
    end
    
    if sum(strcmp(log_acc.task,'ERR')) == 0
        names = cell(1,count+4);
        onsets = cell(1,count+4);
        durations = cell(1,count+4);
    else
        % create and fill in .mat file to be used in SPM first-level analysis
        names = cell(1,count+5);
        onsets = cell(1,count+5);
        durations = cell(1,count+5);
    end
    
    %prods = strcmp(log_acc.task,"prod");
    Qs = strcmp(log_acc.task,"Question");
    Emb = strcmp(log_acc.Voicesaid,"Embedded");
    Coord = strcmp(log_acc.Voicesaid,"Coordinated");
    Fillers = strcmp(log_acc.task,"Filler");
    Err = strcmp(log_acc.task,"ERR");
    No = strcmp(log_acc.task,"Nogo");
    M=[];
    S=[];
    P=[];
    C=[];
    
    for reg=1:length(names)
        if reg<=count % acceptable sentences
            names{reg} = string(reg);
            onsets{reg} = log_acc.PlanOnset(sent(reg));
            durations{reg} = log_acc.PlanDuration(sent(reg)) + log_acc.ProdDuration(sent(reg));
            
            if log_acc.cat_agentsaid(sent(reg))== "S" || log_acc.cat_patientsaid(sent(reg))== "S"
                S(reg) = 1;
            else
                S(reg)=0;
            end
            if log_acc.cat_agentsaid(sent(reg))== "M" || log_acc.cat_patientsaid(sent(reg))== "M"
                M(reg) = 1;
            else
                M(reg)=0;
            end
            if log_acc.cat_verb1said(sent(reg))== "P"
                P(reg) = 1;
                C(reg)=0;
            else
                C(reg) = 1;
                P(reg)=0;
            end
            
        elseif reg == count+1 % other conditions
            names{reg} = "sentread";
            onsets{reg} = log_acc.SentOnset;
            durations{reg} = log_acc.SentDuration;
        elseif reg == count+2
            names{reg} = "number";
            onsets{reg} = log_acc.NumOnset;
            durations{reg} = log_acc.NumDuration;
        elseif reg == count + 3
            names{reg} = "question";
            onsets{reg} = log_acc.ProdOnset(Qs);
            durations{reg} = log_acc.ProdDuration(Qs);
        elseif reg == count + 4
            names{reg} = "fillers";
            onsets{reg} = log_acc.ProdOnset(Fillers);
            durations{reg} =  log_acc.ProdDuration(Fillers);
            %         elseif reg == count + 5
            %             names{reg} = "coordinated";
            %             onsets{reg} = log_acc.ProdOnset(Coord);
            %             durations{reg} = log_acc.ProdDuration(Coord);
        end
    end
    
    
    max=count+5;
    
    
    if sum(strcmp(log_acc.task,'ERR')) > 0
        names{max} = 'ERR';
        onsets{max} = log_acc.ProdOnset(Err);
        durations{max} = log_acc.ProdDuration(Err);%
        
    end
    
    % save summary produced sentences to use for decoding
    log_acc_sent = log_acc(sent,:);
    
    cats = table(M',S',C',P');
    writetable(cats,strcat(firstleveldir,'sub-0', subj, '/', 'cats_them',run_n,'.txt'));
    writetable(log_acc_sent,strcat(firstleveldir,'sub-0', subj, '/', 'sents',run_n,'.csv'));
    save(strcat(firstleveldir,'sub-0', subj, '/', 'sents_prod', run_n, '.mat'), 'names','onsets','durations')
    
    
end
%end

end