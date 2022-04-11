import os
from mvpa2.suite import *
import glob
import pandas as pd
import sys

print sys.argv[0]
s = sys.argv[1]
print(s)
task = sys.argv[2]
print(task)
nruns = int(sys.argv[3])
con1 = int(sys.argv[4])
p = int(sys.argv[5])
print s
print p
print type(p)
mask = 'brain'
print(mask)

#s=2
subj = str(s).zfill(2)
subjdir = 'sub-0'+subj

spmdir = '/project/3011226.02/bids/derivatives/SPM/firstlevel/'+subjdir
fmriprepdir = '/project/3011226.02/bids/derivatives/fmriprep/'+subjdir+'/ses-mri01/func/'
MVPAdir = '/project/3011226.02/bids/derivatives/pyMVPA/'+subjdir+'/cond4/'

# loading production runs

run_datasets = []

if mask == 'brain':

    mask_fname = fmriprepdir+subjdir+'_ses-mri01_task-production_acq-ep3d_run-2_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz'
else:
    mask_fname = '/project/3011226.02/bids/derivatives/ROIs/' + mask +'.nii'


col = task + '_' + mask


count = 0
#sess = "comp_cat_plan"

for run_id in range(con1,con1+nruns*4):

    #for sess in ["mb8all_cond","me3all_cond"]:

    spmT = str(run_id).zfill(4)

    bold_fname = os.path.join(spmdir, task, 'spmT_'+spmT+'.nii.gz')

    run_ds = fmri_dataset(samples = bold_fname, targets = 'M', chunks = count%nruns, mask=mask_fname)
    count += 1
    run_datasets.append(run_ds)

count = 0
for run_id in range(con1+nruns*4,con1+nruns*4+nruns*4):

    spmT = str(run_id).zfill(4)

    bold_fname = os.path.join(spmdir, task, 'spmT_'+spmT+'.nii.gz')

    run_ds = fmri_dataset(samples = bold_fname, targets = 'S', chunks = count%nruns, mask=mask_fname)
    count += 1
    run_datasets.append(run_ds)
    
fds = vstack(run_datasets, a=0)

fds.sa


fds = remove_nonfinite_features(fds)
fds = remove_invariant_features(fds)

zscore(fds)



perm=AttributePermutator("targets", limit="chunks",rng=7*p)

print perm

fds=perm(fds)

print fds.targets

clf = LinearCSVMC()

cvte = CrossValidation(clf, NFoldPartitioner(), errorfx = mean_match_accuracy, postproc = mean_sample(), enable_ca=['stats'])

sl = sphere_searchlight(cvte, radius=5, postproc=mean_sample())

res = sl(fds)

map2nifti(res,imghdr = fds.a.imghdr).to_filename(MVPAdir + '/perms/sl_'+col+'_perm-%.3i.nii.gz' % p)

sphere_acc = res.samples[0]

res_mean = np.mean(res)

res_std = np.std(res)

print res_mean
print res_std

#res.save(os.path.join(MVPAdir, subjdir, 'sl-prod-%.3i.hdf5' % p))

# mean empirical error below chance level: but in all sphere

# check for how many sphere error > 2stds lower than chance
chance_level = (1.0 / len(fds.uniquetargets))

frac_higher = np.round(np.mean(sphere_acc > chance_level + 2 * res_std), 3)
print frac_higher


# PERM2
#p = p + 50
#perm=AttributePermutator("targets", limit="chunks",rng=7*p)

#print perm

#fds=perm(fds)

#print fds.targets

#clf = LinearCSVMC()

#cvte = CrossValidation(clf, NFoldPartitioner(), errorfx = mean_match_accuracy, postproc = mean_sample(), enable_ca=['stats'])

#sl = sphere_searchlight(cvte, radius=5, postproc=mean_sample())

#res = sl(fds)

#map2nifti(res,imghdr = fds.a.imghdr).to_filename(MVPAdir + '/perms/sl_'+col+'_perm-%.3i.nii.gz' % p)

#sphere_acc = res.samples[0]

#res_mean = np.mean(res)

#res_std = np.std(res)

#print res_mean
#print res_std

#res.save(os.path.join(MVPAdir, subjdir, 'sl-prod-%.3i.hdf5' % p))

# mean empirical error below chance level: but in all sphere

# check for how many sphere error > 2stds lower than chance
#chance_level = (1.0 / len(fds.uniquetargets))

#frac_higher = np.round(np.mean(sphere_acc > chance_level + 2 * res_std), 3)
#print frac_higher


