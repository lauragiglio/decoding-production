function [] = specify_first_level(s,task)
%clear all

addpath('/home/common/matlab/spm12/')

%s = 1 %subject number
subj = sprintf('%02d', s);
subjdir = ['sub-0' subj];
%smoothdir = '/project/3011226.01/bids/derivatives/SPM/smooth/';
preprocdir = ['/project/3011226.02/bids/derivatives/fmriprep/sub-0' subj '/ses-mri01/func/'];
firstleveldir = ['/project/3011226.02/bids/derivatives/SPM/firstlevel/' subjdir '/'];
noisedir = '/project/3011226.02/bids/derivatives/noise_regs/';


spm('defaults','fmri');
spm_jobman('initcfg'); 
  

%% define batch

matlabbatch{1}.spm.stats.fmri_spec.dir = {[firstleveldir task]};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 0.7;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

% gunzip files 
files=dir(strcat(preprocdir, '*task-production_acq-ep3d_run-*_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'));
if isempty(files)
    gunzip([preprocdir '*task-production_acq-ep3d_run-*_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'])
    delete([preprocdir '*task-production_acq-ep3d_run-*_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'])
end

nrun=6;
for i = 1:nrun
    run = int2str(i);
    files=dir(strcat(preprocdir, '*task-production_acq-ep3d_run-', run ,'_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'));
    regfile = readtable([noisedir subjdir '_noiseregs_run-' run '.txt']);
    count=1;
    for n=6:(height(regfile)+5)
        vol = num2str(n);
        voladd = [',' vol];
        temp = {preprocdir, files.name, voladd};
        matlabbatch{1}.spm.stats.fmri_spec.sess(i).scans{count,1} = horzcat(temp{:});
        count = count+1;
    end
    
    % specify condition .mat file and nuisance regressors .txt file
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).multi = {[firstleveldir task run '.mat']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).multi_reg = {[noisedir subjdir '_noiseregs_run-' run '.txt']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).hpf = 128;
end

matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
%matlabbatch{1}.spm.stats.fmri_spec.mask = {[preprocdir '/sub-p001_ses-mri01_task-Production_acq-ep3d_run-1_space-MNI152NLin2009cAsym_desc-brain_mask.nii,1']};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'FAST';

%% run job
spm_jobman('run',matlabbatch);

end