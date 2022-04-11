import os
from mvpa2.suite import *
import glob
import tempfile, shutil
import sys

task = sys.argv[1]
print(task)

MVPAdir = '/project/3011226.02/bids/derivatives/pyMVPA/'

subjectlist = range(1,41)
# load accuracy map for original targets
#mask = 'brain'
mask = 'brain'
subj_datasets = []


MVPAdir = '/project/3011226.02/bids/derivatives/pyMVPA/'

if mask == 'brain':
    mask_fname = '/project/3011226.02/bids/derivatives/SPM/grouplevel/voice_univariate/mask.nii'
else:
    mask_fname = '/project/3011226.02/bids/derivatives/ROIs/' + mask +'.nii'

for s in subjectlist:

    subj = str(s).zfill(2)

    subjdir = 'sub-0'+subj
    
    subj_ds = fmri_dataset(os.path.join(MVPAdir, subjdir, 'cond4/sl_'+task+'_'+ mask +'.nii.gz'), chunks=s, mask=mask_fname)

    subj_datasets.append(subj_ds)

acc_maps = vstack(subj_datasets,a=0)

del subj_datasets

# load permuted maps
perm_datasets = []
for s in subjectlist:
    subj = str(s).zfill(2)
    subjdir = 'sub-0'+subj

    tmaps = glob.glob(os.path.join(MVPAdir, subjdir, 'cond4/perms/sl_'+task+'_'+ mask +'_perm-*')) 
    if len(tmaps) != 100:        
        print subj
        print len(tmaps)

# load permuted maps
perm_datasets = []
for s in subjectlist:
    subj = str(s).zfill(2)
    subjdir = 'sub-0'+subj

    tmaps = glob.glob(os.path.join(MVPAdir, subjdir, 'cond4/perms/sl_'+task+'_'+ mask +'_perm-*'))  
    if len(tmaps) == 100:        
        for perm in tmaps:
            perm_ds = fmri_dataset(perm, chunks=s, mask=mask_fname)
            perm_datasets.append(perm_ds)
    

perm_maps = vstack(perm_datasets, a=0)

del perm_datasets

feature_thresh_prob = .001

fwe_rate = .05

multicomp_correction = 'fdr_bh'

bootstrap = int(1e5)


# use n_blocks = 1000 to reduce memory load when using larger bootstrap sample?

cluster = GroupClusterThreshold(n_bootstrap=bootstrap,

                                feature_thresh_prob=feature_thresh_prob,

                                chunk_attr='chunks',

                                n_blocks=1000,

                                n_proc=4,

                                fwe_rate=fwe_rate,

                                multicomp_correction=multicomp_correction)

# train bootstrapping of permutation results on permuted maps

cluster.train(perm_maps)

# estimate significance/threshold of accuracy maps
cluster_map = cluster(acc_maps)

h5save(os.path.join(MVPAdir,task+'_'+mask+'_stats.hdf5'),cluster_map,compression=9)

map2nifti(cluster_map,cluster_map.samples).to_filename(os.path.join(MVPAdir, task+'_'+mask+'_avg_acc.nii.gz'))

map2nifti(cluster_map,cluster_map.fa.clusters_fwe_thresh).to_filename(os.path.join(MVPAdir, task+'_'+mask+'_fweclusters.nii.gz'))

map2nifti(cluster_map,cluster_map.fa.featurewise_thresh).to_filename(os.path.join(MVPAdir, task+'_'+mask+'_featurewisethresh.nii.gz'))



