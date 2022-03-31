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
    task_regs_voice_single(s)
end

%% first level analysis

for s = 4:40
    req_mem   = 8000000000;
    req_time = 3600;
    jobs{s} = qsubfeval(@specify_first_level, s, 'voice_single',  'memreq',  req_mem,  'timreq',  req_time);
end
%save 'jobs.mat' jobs

for s = 3:40
    req_mem   = 12000000000;
    req_time = 3600;
    jobsest{s} = qsubfeval(@estimate_first_level, s, 'voice_single',  'memreq',  req_mem,  'timreq',  req_time);
end

for s = 1:40
    req_mem   = 4000000000;
    req_time = 600;
    jobsest{s} = qsubfeval(@contrasts_cat_single, s, 'voice_single', 0, 'memreq',  req_mem,  'timreq',  req_time);
end

for s = 1:40
    req_mem   = 4000000000;
    req_time = 600;
    jobsest{s} = qsubfeval(@contrasts_cat_univariate, s, 'voice_single', 1, 'memreq',  req_mem,  'timreq',  req_time);
end



