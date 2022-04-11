# -*- coding: utf-8 -*-
"""
Created on Fri Apr  1 14:42:47 2022

@author: laugig
"""

import os
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import random

# excel files with t-test
accs = pd.read_csv('P:/3011226.02/bids/derivatives/pyMVPA/cond4/class_acc.csv')

s=1
subj = str(s).zfill(2)
subjdir = 'sub-0'+subj
files = os.listdir("P:/3011226.02/bids/derivatives/pyMVPA/"+subjdir+"/allsents/accs/")
for file in files:
    print(file)
    if ('txt' in file) & ('perms' not in file):
        task = file[:-4]
        if task not in accs.columns:
            accs[task] = 0

for s in range(1,41):
    subj = str(s).zfill(2)
    subjdir = 'sub-0'+subj
    files = os.listdir("P:/3011226.02/bids/derivatives/pyMVPA/"+subjdir+"/allsents/accs/")
    for file in files:
        if ('txt' in file) & ('perms' not in file):
            task = file[:-4]
            with open("P:/3011226.02/bids/derivatives/pyMVPA/"+subjdir+"/allsents/accs/"+file) as f:
                lines = f.readlines()
            accs[task][accs.subject==subjdir] = lines
        
accs.to_csv('P:/3011226.02/bids/derivatives/pyMVPA/allsents/class_acc.csv')        


# permutation tests
s=1
subj = str(s).zfill(2)
subjdir = 'sub-0'+subj

#oldaccs = pd.read_csv('P:/3011226.02/bids_new/derivatives/pyMVPA/single/acc_sign_perm.csv')

decacc = pd.DataFrame(index=range(0,120),columns={'task','perc','acc','pvalue'})
perms_sub = pd.DataFrame(index=range(0,100),columns={'permn'})

files = os.listdir("P:/3011226.02/bids/derivatives/pyMVPA/"+subjdir+"/allsents/accs/")
n=0

for file in files:
    if 'perms.txt' in file: # and file not in oldaccs.task.tolist():
        print(file)
        decacc.task[n]=file
        permsall=[]
        for s in range(1,41):
            subj = str(s).zfill(2)
            subjdir = 'sub-0'+subj
            with open("P:/3011226.02/bids/derivatives/pyMVPA/"+subjdir+"/allsents/accs/"+file,'r') as f:
                perms = f.read().split(', ')
            
            perms[0] = perms[0][1:]
            perms[-1] = perms[-1][:-1]
            perms = [float(x) for x in perms]
            perms_sub[subj] = perms
            #[permsall.append(x) for x in perms]
        #plt.hist(perms,density=True,bins=30)
        
        #perc = np.percentile(perms,95)
        for p in range(100000):
            ran_list = [random.sample(perms_sub.iloc[:,1].tolist(),1),random.sample(perms_sub.iloc[:,2].tolist(),1)]
            permsall.append(np.mean(ran_list))
            #if p%1000 ==0:
            #    print(p)
        perc = np.percentile(permsall,95)
        plt.hist(permsall,density=True,bins=30)
        
        decacc.perc[n]=perc
        acc=[]
        for s in range(1,41):
            subj = str(s).zfill(2)
            subjdir = 'sub-0'+subj

            with open("P:/3011226.02/bids/derivatives/pyMVPA/"+subjdir+"/allsents/accs/"+file[:-10]+'.txt') as f:
                lines = f.readlines()
            acc.append(float(lines[0]))
            
        decacc.acc[n] = np.mean(acc)
        decacc.pvalue[n] = sum(permsall>np.mean(acc))/100000
        n=n+1
        
decacc.to_csv('P:/3011226.02/bids/derivatives/pyMVPA/allsents/acc_sign_perm.csv')

plt.hist(permsall,density=True,bins=30)
plt.hist(accs.voice_cat_syntactic_z)
