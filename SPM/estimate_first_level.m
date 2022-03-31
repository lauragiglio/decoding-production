%% estimate first level for production/comprehension runs
% need to have specified first level SPM.mat file

function [] = estimate_first_level(s,task)
% s = subject number
%  task = firstlevel folder
%clear all

addpath('/home/common/matlab/spm12/')
firstleveldir = '/project/3011226.02/bids/derivatives/SPM/firstlevel/';

%s = 1 %subject number

subj = ['sub-0' sprintf('%02d', s)];


spm('defaults','fmri');
spm_jobman('initcfg'); 

matlabbatch{1}.spm.stats.fmri_est.spmmat = {[firstleveldir subj '/' task '/SPM.mat']};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

% run job
spm_jobman('run',matlabbatch);
end