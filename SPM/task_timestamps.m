function [] = task_timestamps(s)
% s = subject number
% function to retrieve times of each sentence comp and prod
% outputs sub-0xx_log_acc-times_run-x.csv file to be used to create task
% regressors of interest

%% 
s
subj = sprintf('%02d', s);

behavdir = ['/project/3011226.02/bids/derivatives/behav/sub-0' subj '/'];
%preprocdir = ['/project/3011226.02/bids/derivatives/fmriprep/sub-0' subj '/ses-mri01/func/'];
conddir = ['/project/3011226.02/bids/derivatives/condition_times/'];

nruns = 6;


for i = 1:nruns
    clear names
    clear onsets
    clear durations
    
    run_n = string(i);
    
 %% import all input files  
 
    % import presentation logfile with time of trials
    runorder = readtable(strcat(behavdir, 'sub-0', subj,'.txt'), 'FileType','text','ReadVariableNames', 1,'HeaderLines',0);
    log_times = readtable(strcat(behavdir, subj, "_", run_n, "_", string(runorder.Order(i)), "_logfile.txt"), 'FileType','text','ReadVariableNames', 1,'HeaderLines',0);
    log_pulses = readtable(strcat(behavdir, subj, "_", run_n, "_P.csv"), 'FileType','text','ReadVariableNames', 1);
    time0 = log_pulses.Time((log_pulses.Pulse ==log_times.PulseCountBeg(1)) & log_pulses.EventType == "Pulse")/10; % correct tenth of ms in Presentation
    if isempty(time0) 
        time0 = log_times.TimeStartTrial(1) - 227; % 227 is mean delay from pulse to start function (200 ms fixation + compute time?)
        time0
    end
        % Pulse 6 is time zero: needs to be subtracted from all values in
     
    % onset and offset times
    log_praat = readtable(strcat(behavdir, "run", run_n, "/filtered/onsets_durationAutomatic.txt"), 'Delimiter', '\t');
    log_praat.Properties.VariableNames = {'PraatTrial' 'TrialName' 'Onset' 'Offset'};
    
    % need to sort durations after praat's weird ordering
    trial_names = log_praat.TrialName;
    %log_praat.Var5 = str2double(log_praat.Var5);
    t = cell(size(log_praat,1),1);
    for n = 1:size(log_praat,1)
        t{n} = strsplit(trial_names{n}, '_');
        log_praat.trial_n(n) = str2double(t{n}{3});
    end
    log_praat = sortrows(log_praat, 5);
    
    % check if order run is correct
    list_run = log_times.Input_Run(1); % find which list was used for this run - the list includes accuracy coding
    list_run == runorder.Order(i);
    
    % import list with accuracy coding (access correct run file by looking
    % up order of runs in runorder
    log_acc = readtable(strcat(behavdir, "run", string(runorder.Order(i)), ".xlsx"));
    
%% preprocess accuracy file

    % mark production error trials
    log_acc.task_original = log_acc.task;
    
    % check if production trials are said as fillers
    for t = 1:size(log_acc,1)
        if log_acc.task{t} == "prod" && (log_acc.Voicesaid{t} == "Coordinated" || log_acc.Voicesaid{t} == "Embedded")
            log_acc.task{t} = 'Filler';
        end
    end
    for t = 1:size(log_acc,1)
        if log_acc.Acceptable(t) == 2 && log_acc.task(t) ~= "Question"
            log_acc.task{t} = 'ERR';
        end
    end
    
    % create new categories for actually said nouns and verbs (include
    % female versions of nouns)
    M = {'cellist','drummer','gitarist','muzikant','pianist','saxofonist','violist','zanger','zangeres'};
    S = {'atleet','bokser','schaatser','surfer','turner','voetballer','wielrenner','zwemmer','turnster'};
    C = {'aanvallen','grijpen','knijpen','krabben','schoppen','trappen','vasthouden','wegduwen'};
    P = {'aanstaren','begluren','bekijken','herkennen','ontdekken','opmerken','waarnemen','zien'};
    
    for trial=1:size(log_acc,1)
        if log_acc.task(trial) ~= "ERR" && log_acc.task(trial) ~= "Filler"
            if ismember(log_acc.agentsaid(trial),S)
                log_acc.cat_agentsaid(trial) = 'S';
            elseif ismember(log_acc.agentsaid(trial),M)
                log_acc.cat_agentsaid(trial) = 'M';
            else
                log_acc.agentsaid(trial)
                log_acc.cat_agentsaid(trial) = 'E';
            end
            if ismember(log_acc.patientsaid(trial),S)
                log_acc.cat_patientsaid(trial) = 'S';
            elseif ismember(log_acc.patientsaid(trial),M)
                log_acc.cat_patientsaid(trial) = 'M';
            else
                log_acc.patientsaid(trial)
                log_acc.cat_patientsaid(trial) = 'E';
            end
            if ismember(log_acc.noun1said(trial),S)
                log_acc.cat_noun1said(trial) = 'S';
            elseif ismember(log_acc.noun1said(trial),M)
                log_acc.cat_noun1said(trial) = 'M';
            else
                log_acc.noun1said(trial)
                log_acc.cat_noun1said(trial) = 'E';
            end
            if ismember(log_acc.noun2said(trial),S)
                log_acc.cat_noun2said(trial) = 'S';
            elseif ismember(log_acc.noun2said(trial),M)
                log_acc.cat_noun2said(trial) = 'M';
            else
                log_acc.noun2said(trial)
                log_acc.cat_noun2said(trial) = 'E';
            end
            if ismember(log_acc.verb1said(trial),C)
                log_acc.cat_verb1said(trial) = 'C';
            elseif ismember(log_acc.verb1said(trial),P)
                log_acc.cat_verb1said(trial) = 'P';
            else
                log_acc.verb1said(trial)
                log_acc.cat_verb1said(trial) = 'E';
            end
        else
            log_acc.cat_agentsaid(trial) = 'F';
            log_acc.cat_patientsaid(trial) = 'F';
            log_acc.cat_noun1said(trial) = 'F';
            log_acc.cat_noun2said(trial) = 'F';
            log_acc.cat_verb1said(trial) = 'F';
        end
    end
    
    % category combinations by thematic roles and syntactic (order roles)
    log_acc.CatThem = strcat(log_acc.cat_agentsaid, log_acc.cat_patientsaid,log_acc.cat_verb1said);
    log_acc.CatSynt = strcat(log_acc.cat_noun1said, log_acc.cat_noun2said,log_acc.cat_verb1said);
    
    
%% find timings for each condition

    for trial = 1:height(log_acc)
        
        log_acc.SentOnset(trial) = (log_times.TimeStartSent(trial) - time0)/1000;%
        log_acc.SentDuration(trial) = (log_times.TimeEndSent(trial) - log_times.TimeStartSent(trial))/1000;%
        log_acc.NumOnset(trial) = (log_times.DistPres1(trial) - time0)/1000;%
        log_acc.NumDuration(trial) = (log_times.FeedbackDist(trial) - log_times.DistPres1(trial))/1000;%
        
        if log_acc.task(trial) == "prod"
            log_acc.PlanOnset(trial) = (log_times.FeedbackDist(trial) - time0)/1000;
            log_acc.PlanDuration(trial) = log_praat.Onset(trial);
            log_acc.ProdOnset(trial) = (log_times.FeedbackDist(trial) - time0)/1000 + log_praat.Onset(trial);
            log_acc.ProdDuration(trial) = log_praat.Offset(trial) - log_praat.Onset(trial);
        elseif log_acc.task(trial) == "Question"
            log_acc.PlanOnset(trial) = (log_times.FeedbackDist(trial) - time0)/1000;
            log_acc.PlanDuration(trial) = (300 + log_times.JitterPlan(trial))/1000;
            log_acc.ProdOnset(trial) = (log_times.FeedbackDist(trial) + 300 + log_times.JitterPlan(trial) - time0)/1000 + 0.6; % why + 0.6?!?!
            log_acc.ProdDuration(trial) = log_times.TimetoAnswerQ(trial)/1000;
        elseif log_acc.task(trial) == "Filler" || log_acc.task(trial) == "ERR"
            if log_acc.Distraction(trial) == "DistFirst" || log_acc.Distraction(trial) == "DistLast"
                log_acc.PlanOnset(trial) = (log_times.TimeEndSent(trial) + 800 - time0)/1000;
                log_acc.ProdOnset(trial) = (log_times.TimeEndSent(trial) + 800 - time0)/1000 + log_praat.Onset(trial); % when recording starts
            else
                log_acc.PlanOnset(trial) = (log_times.FeedbackDist(trial) - time0)/1000;
                log_acc.ProdOnset(trial) = (log_times.FeedbackDist(trial) - time0)/1000 + log_praat.Onset(trial);
            end
            log_acc.PlanDuration(trial) = log_praat.Onset(trial);
            log_acc.ProdDuration(trial) = log_praat.Offset(trial) - log_praat.Onset(trial);
            
        end
    end
    
    writetable(log_acc,strcat(conddir,'sub-0', subj, '_log_acc-times_run-',run_n,'.csv'));
    
end

