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
MVPAdir = '/project/3011226.02/bids/derivatives/pyMVPA/'+subjdir+'/single/'

# loading production runs
if not os.path.isdir(MVPAdir):
    os.mkdir(MVPAdir)

if not os.path.isdir(os.path.join(MVPAdir,'accs')):
    os.mkdir(os.path.join(MVPAdir,'accs'))

if not os.path.isdir(os.path.join(MVPAdir,'perms')):
    os.mkdir(os.path.join(MVPAdir,'perms'))  
  
run_datasets = []

if mask == 'brain':

    mask_fname = fmriprepdir+subjdir+'_ses-mri01_task-production_acq-ep3d_run-2_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz'
else:
    mask_fname = '/project/3011226.02/bids/derivatives/ROIs/' + mask +'.nii'


col = task + '_' + mask


count = 0
#sess = "comp_cat_plan"

for run_id in range(con1,con1+nruns):

    #for sess in ["mb8all_cond","me3all_cond"]:

    spmT = str(run_id).zfill(4)

    bold_fname = os.path.join(spmdir, task, 'spmT_'+spmT+'.nii')

    run_ds = fmri_dataset(samples = bold_fname, targets = 'M', chunks = count%nruns, mask=mask_fname)
    count += 1
    run_datasets.append(run_ds)

count = 0
for run_id in range(con1+nruns,con1+nruns+nruns):

    spmT = str(run_id).zfill(4)

    bold_fname = os.path.join(spmdir, task, 'spmT_'+spmT+'.nii')

    run_ds = fmri_dataset(samples = bold_fname, targets = 'S', chunks = count%nruns, mask=mask_fname)
    count += 1
    run_datasets.append(run_ds)
    
fds = vstack(run_datasets, a=0)

fds.sa


fds = remove_nonfinite_features(fds)


## PERMUTATIONS
res1=[]
for p in range(1,101):
    perm=AttributePermutator("targets", limit="chunks",rng=7*p)

    print perm

    fds=perm(fds)

    print fds.targets

    clf = LinearCSVMC()

    cvte = CrossValidation(clf, NFoldPartitioner(cvtype=1),

                           errorfx=lambda p, t: np.mean(p == t),

                           enable_ca=['stats'])

    cv_results = cvte(fds)

    res1.append(np.mean(cv_results))
    #print(res1)
    

with open("/project/3011226.02/bids/derivatives/pyMVPA/"+subjdir+"/single/accs/"+col+"_perms.txt", "w") as text_file:
    text_file.write(str(res1))

    
# after zscoring

# z-score features individually per chunk

zscore(fds)

res2=[]
for p in range(1,101):
    perm=AttributePermutator("targets", limit="chunks",rng=7*p)

    print perm

    fds=perm(fds)

    print fds.targets
  


    clf = LinearCSVMC()

    cvte = CrossValidation(clf, NFoldPartitioner(cvtype=1),

                           errorfx=lambda p, t: np.mean(p == t),

                           enable_ca=['stats'])

    cv_results = cvte(fds)

    res2.append(np.mean(cv_results))
#    print(res2)
 #   with open("/project/3011226.02/bids_pilot/derivatives/pyMVPA/"+subjdir+"/"+col+"_z.txt", "w") as text_file:
#        text_file.write(str(res2))
    
with open("/project/3011226.02/bids/derivatives/pyMVPA/"+subjdir+"/single/accs/"+col+"_z_perms.txt", "w") as text_file:
    text_file.write(str(res2))   

    
    