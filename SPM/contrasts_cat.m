function [] = contrasts_cat(s,task,del)
%clear all
% del = 1 if want to delete previous contrasts, 0 if want to keep them
addpath('/home/common/matlab/spm12/')

%s = 1 %subject number
subj = ['sub-0' sprintf('%02d', s)];
addpath('/home/common/matlab/spm12/')

firstleveldir = ['/project/3011226.02/bids/derivatives/SPM/firstlevel/'];
%s = 1 %subject number
subj = ['sub-0' sprintf('%02d', s)];


spm('defaults','fmri');
spm_jobman('initcfg'); 
%%
matlabbatch{1}.spm.stats.con.spmmat = {[firstleveldir subj '/' task '/SPM.mat']};

matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'M1';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 0];
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'sess';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'M2';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 0 1 0];
matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'sess';
matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'M3';
matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0 0 0 0 1 0];
matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'sess';
matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'M4';
matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 0 0 0 1 0];
matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'sess';
matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'S1';
matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 0 0 0 0 1 0];
matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'sess';
matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'S2';
matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 1 0];
matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'sess';
matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'S3';
matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 1 0];
matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'sess';
matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'S4';
matlabbatch{1}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0];
matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'sess';

matlabbatch{1}.spm.stats.con.delete = del;

% run job
spm_jobman('run',matlabbatch);
%end