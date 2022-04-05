%% pipeline to run (all) first-level analyses in SPM
clear all
cd /project/3011226.02/scripts/SPM
addpath '/home/common/matlab/fieldtrip/qsub'

%% task timings
for s = [35,38]
    task_timestamps(s)
end

%% task regressors
for s = 1:40
    task_regs_sent_prod(s)
end

%% first level analysis

for s = 2:40
    req_mem   = 16000000000;
    req_time = 3600;
    jobs{s} = qsubfeval(@specify_first_level, s, 'sents_prod',  'memreq',  req_mem,  'timreq',  req_time);
end
%save 'jobs.mat' jobs

for s = 1:40
    req_mem   = 16000000000;
    req_time = 14400; % 4 hours
    jobsest{s} = qsubfeval(@estimate_first_level, s, 'sents_prod',  'memreq',  req_mem,  'timreq',  req_time);
end

for s = 1:40
    req_mem   = 6000000000;
    req_time = 3600;
    jobscon{s} = qsubfeval(@contrasts_cat, s, 'sents_prod', 1, 'memreq',  req_mem,  'timreq',  req_time);
end

% for s = 1:40
%     req_mem   = 4000000000;
%     req_time = 600;
%     jobsest{s} = qsubfeval(@contrasts_cat_univariate, s, 'voice_single', 0, 'memreq',  req_mem,  'timreq',  req_time);
% end

for s = 1:40
    subj = sprintf('%02d', s);
    subjdir = ['sub-0' subj];

    mkdir(['/project/3011226.02/bids/derivatives/pyMVPA/' subjdir '/allsents/accs'])
    mkdir(['/project/3011226.02/bids/derivatives/pyMVPA/' subjdir '/allsents/perms'])
end
