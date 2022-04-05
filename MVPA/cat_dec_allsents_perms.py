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
#nruns = int(sys.argv[3])
#con1 = int(sys.argv[4])
mask = sys.argv[3]
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

        
                   
### PERMUTATIONS
res1=[]

for p in range(1,101):
    perm=AttributePermutator("targets", limit="chunks",rng=7*p)

    print perm

    fds=perm(fds)

    #print fds.targets

    clf = LinearCSVMC()

    cvte = CrossValidation(clf, NFoldPartitioner(),

                           errorfx=lambda p, t: np.mean(p == t),

                           enable_ca=['stats'])

    cv_results = cvte(fds)

    res1.append(np.mean(cv_results))
    #print(res1)
    
with open(MVPAdir+"accs/"+col+"_perms.txt", "w") as text_file:
    text_file.write(str(res1))


# z-score features individually per chunk
zscore(fds)

res2=[]
for p in range(1,101):

    clf = LinearCSVMC()

    cvte = CrossValidation(clf, NFoldPartitioner(),

                           errorfx=lambda p, t: np.mean(p == t),

                           enable_ca=['stats'])

    cv_results = cvte(fds)

    res2.append(np.mean(cv_results))
#    print(res2)
 #   with open("/project/3011226.02/bids_pilot/derivatives/pyMVPA/"+subjdir+"/"+col+"_z.txt", "w") as text_file:
#        text_file.write(str(res2))


    
with open(MVPAdir+"/accs/"+col+"_z_perms.txt", "w") as text_file:
    text_file.write(str(res2))   
                    
                    
                        
    

    
    