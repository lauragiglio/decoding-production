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
mask = sys.argv[5]
print(mask)

#s=2
subj = str(s).zfill(2)
subjdir = 'sub-0'+subj

spmdir = '/project/3011226.02/bids/derivatives/SPM/firstlevel/'+subjdir
fmriprepdir = '/project/3011226.02/bids/derivatives/fmriprep/'+subjdir+'/ses-mri01/func/'
MVPAdir = '/project/3011226.02/bids/derivatives/pyMVPA/'+subjdir+'/allsents/'

# loading production runs

run_datasets = []

if mask == 'brain':

    mask_fname = fmriprepdir+subjdir+'_ses-mri01_task-production_acq-ep3d_run-2_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz'
else:
    mask_fname = '/project/3011226.02/bids/derivatives/ROIs/' + mask +'.nii'


col = task + '_' + mask


# load attributes previously created with create_sampleAttr_bysent
attr_fname = MVPAdir+task+'.txt'
attr = SampleAttributes(attr_fname)

bold_fname = []
for run_id in range(1,len(attr.chunks)+1):

    spmT = str(run_id).zfill(4)
    bold_fname.append(os.path.join(spmdir, 'sents_prod', 'spmT_'+spmT+'.nii.gz'))

    
run_ds = fmri_dataset(samples = bold_fname, targets = attr.targets, chunks = attr.chunks, mask=mask_fname)
    
fds = vstack(run_ds, a=0)
fds = remove_nonfinite_features(fds)
fds = remove_invariant_features(fds)

# next only works with floating point data

fds.samples = fds.samples.astype('float')

pl.figure(figsize=(14, 6))

pl.subplot(121)

plot_samples_distance(fds, sortbyattr='chunks')

pl.title('Sample distances (sorted by chunks)')

pl.subplot(122)

plot_samples_distance(fds, sortbyattr='targets')

pl.title('Sample distances (sorted by targets)')

pl.savefig(os.path.join(MVPAdir, col+'.png'), dpi=150)

clf = LinearCSVMC()

cvte = CrossValidation(clf, NFoldPartitioner(),

                       errorfx=lambda p, t: np.mean(p == t),

                       enable_ca=['stats'])

cv_results = cvte(fds)

res1 = np.mean(cv_results)
print(res1)
with open(MVPAdir+"/accs/"+col+".txt", "w") as text_file:
    text_file.write(str(res1))

                    
                    
# z-score features individually per chunk

zscore(fds)

pl.figure(figsize=(14, 6))

pl.subplot(121)

plot_samples_distance(fds,sortbyattr='chunks')

pl.title('Distances: z-scored, detrended (sorted by chunks)')

pl.subplot(122)

plot_samples_distance(fds, sortbyattr='targets')

pl.title('Distances: z-scored, detrended (sorted by targets)')

pl.savefig(os.path.join(MVPAdir, col+'_z.png'), dpi=150)

clf = LinearCSVMC()

cvte = CrossValidation(clf, NFoldPartitioner(),

                       errorfx=lambda p, t: np.mean(p == t),

                       enable_ca=['stats'])

cv_results = cvte(fds)

res2 = np.mean(cv_results)
print(res2)
with open(MVPAdir+"/accs/"+col+"_z.txt", "w") as text_file:
    text_file.write(str(res2))

                    
                    
### SEARCHLIGHT
if mask == 'GMunion':
    clf = LinearCSVMC()

    cvte = CrossValidation(clf, NFoldPartitioner(), errorfx = mean_match_accuracy, postproc = mean_sample(), enable_ca=['stats'])

    # split dataset into all possible sphere neighbourhoods that intersect with the brain

    sl = sphere_searchlight(cvte, radius=5, postproc=mean_sample())

    res = sl(fds)

    res.samples

    sphere_errors = res.samples[0]
    res_mean = np.mean(res)
    res_std = np.std(res)
    # we deal with errors here, hence 1.0 minus
    chance_level = 1.0 - (1.0 / len(fds.uniquetargets))
    chance_level
    print(res_mean)

    #map2nifti(fds, 1.0 - sphere_errors).to_filename(MVPAdir+'/sl_'+col+'.nii.gz')
    map2nifti(res,imghdr = fds.a.imghdr).to_filename(MVPAdir + '/sl_'+col+'.nii.gz')
    

    
    
    
